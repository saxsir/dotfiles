#!/bin/bash
# GitHub へ投稿する本文に Issue / PR の短縮参照 (#123) が混ざるのを止める
# PreToolUse フック (rules/github-writing.md「根拠を示す」の機械的強制)。
# 短縮形は同一リポジトリ内でしか解決されないため、別リポの Issue を指すつもりで
# #123 と書くと、現在のリポジトリの無関係な #123 へ黙ってリンクされる。
# 投稿後に気づく手がかりが無く、後から参照をたどれなくなる。
#
# hook に見えるのは本文の文字列だけで、その #123 が同一リポのつもりか
# 別リポのつもりかは判別できない。実在確認で通そうとしても、現在のリポに
# 偶然同じ番号があれば素通りする — 防ぎたい事故そのものなので採らない。
# だから同一リポ参照も含めて一律に落とし、常にフル URL を書かせる。
#
# 本文の取得元は gh pr/issue 系の --body / -b / --body-file / -F <file> と、
# gh api の -f body= / -F body=@<file> / --input <file>。
# title は見ない (短縮参照が入る頻度が低く、検査を body に集中させる)。
# commit message も対象外 (別の話なので責務を分ける)。
# GitHub MCP の書き込みツールは未登録なので経路として存在しない。
#
# ファイルが読めない・コマンド展開 ($(cat f)) で渡された場合は素通しする。
# 脅威モデルは正常動作での事故防止であって、難読化したすり抜けではない。
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -n "$CMD" ] || exit 0
echo "$CMD" | grep -q 'gh' || exit 0

FOUND=$(CMD="$CMD" CWD="$CWD" perl -e '
use strict; use warnings;

# スクリプト全体が bash のシングルクォートに入るので、リテラルの
# シングルクォートは書けない。chr(39) で作る。
my $SQ = chr(39);

# --- シェル引数のトークナイズ (引用符を解釈し、値そのものを取り出す) ---
# block-gh-body-overwrite.sh は引用符の中身を潰してフラグ列だけ見るが、
# こちらは中身が検査対象なので逆に中身を残す必要がある。
sub tokenize {
  my ($s) = @_;
  my @tokens; my $cur; my $has = 0;
  my @chars = split //, $s;
  my $i = 0;
  while ($i < @chars) {
    my $c = $chars[$i];
    if ($c eq $SQ) {                          # シングルクォート: 中身は全てリテラル
      $i++; $has = 1;
      while ($i < @chars && $chars[$i] ne $SQ) { $cur .= $chars[$i]; $i++ }
      $i++;
    } elsif ($c eq q{"}) {                    # ダブルクォート: バックスラッシュのみ解釈
      $i++; $has = 1;
      while ($i < @chars && $chars[$i] ne q{"}) {
        if ($chars[$i] eq q{\\} && $i + 1 < @chars) { $i++ }
        $cur .= $chars[$i]; $i++;
      }
      $i++;
    } elsif ($c eq q{\\} && $i + 1 < @chars) {
      $i++; $cur .= $chars[$i]; $i++; $has = 1;
    } elsif ($c =~ /\s/) {
      push @tokens, { v => $cur, sep => 0 } if $has;
      $cur = undef; $has = 0;
      push @tokens, { v => q{;}, sep => 1 } if $c eq qq{\n};
      $i++;
    } elsif ($c =~ /[;|&]/) {                 # コマンド区切り (引用の外だけ)
      push @tokens, { v => $cur, sep => 0 } if $has;
      $cur = undef; $has = 0;
      $i++;
      $i++ while $i < @chars && $chars[$i] eq $c;
      push @tokens, { v => q{;}, sep => 1 };
    } else {
      $cur .= $c; $i++; $has = 1;
    }
  }
  push @tokens, { v => $cur, sep => 0 } if $has;
  return @tokens;
}

# --- GitHub がリンク化しない箇所を落とす ---
# fenced code block とインラインコードの中は GitHub が #123 をリンクしないので、
# 検査対象から外す。details に貼るログや shebang での誤検知はここで消える。
sub strip_code {
  my ($t) = @_;
  $t =~ s/^[ \t]*(`{3,}|~{3,})[^\n]*\n.*?^[ \t]*\1[ \t]*$//gms;  # 閉じたフェンス
  $t =~ s/^[ \t]*(`{3,}|~{3,})[^\n]*\n.*\z//ms;                  # 閉じ忘れは末尾まで
  $t =~ s/(`+)(?:(?!\1).)*?\1//gs;                               # インラインコード
  return $t;
}

sub scan {
  my ($t) = @_;
  $t = strip_code($t);
  my @hits;
  # 直前が行頭か空白・約物、直後が英数/_/- でないものだけ拾う。
  # URL のフラグメント (…/pull/1#issuecomment-123) は直前が非空白なので外れる。
  while ($t =~ /(?:^|[\s(\[{>,])\#(\d+)(?![0-9A-Za-z_-])/gm) { push @hits, $1 }
  return @hits;
}

sub read_body_file {
  my ($p) = @_;
  return () if !defined $p || $p eq q{-} || $p =~ /^<\(/;   # stdin / process substitution は読めない
  $p =~ s/^~/$ENV{HOME}/;
  $p = "$ENV{CWD}/$p" if $p !~ m{^/} && defined $ENV{CWD} && $ENV{CWD} ne q{};
  open my $fh, q{<}, $p or return ();                       # 読めなければ素通し (fail-open)
  local $/; my $c = <$fh>; close $fh;
  return defined $c ? ($c) : ();
}

my @tokens = tokenize($ENV{CMD});

# 区切りごとに 1 コマンドへ切り出す
my @cmds; my @cur;
for my $t (@tokens) {
  if ($t->{sep}) { push @cmds, [@cur] if @cur; @cur = (); next }
  push @cur, $t->{v};
}
push @cmds, [@cur] if @cur;

my @found;
for my $c (@cmds) {
  my @a = @$c;
  # 先頭の環境変数代入を読み飛ばす
  shift @a while @a && $a[0] =~ /^\w+=/;
  next unless @a && $a[0] eq q{gh};

  my @words = grep { !/^-/ } @a[1 .. $#a];
  my $is_api   = (grep { $_ eq q{api} } @words) ? 1 : 0;
  my $is_issue = (grep { $_ eq q{pr} || $_ eq q{issue} } @words) ? 1 : 0;
  next unless $is_api || $is_issue;

  my @bodies;
  for my $i (1 .. $#a) {
    my $t = $a[$i];
    my $n = $i < $#a ? $a[$i + 1] : undef;

    if ($is_issue) {
      # gh pr/issue: -F は --body-file の短縮形
      push @bodies, $n            if ($t eq q{--body} || $t eq q{-b}) && defined $n;
      push @bodies, $1            if $t =~ /^--body=(.*)$/s;
      push @bodies, read_body_file($n) if ($t eq q{--body-file} || $t eq q{-F}) && defined $n;
      push @bodies, read_body_file($1) if $t =~ /^--body-file=(.*)$/s;
    }
    if ($is_api) {
      # gh api: -F body=@<file> はファイル渡し、-f body= は直書き
      my $field;
      if    ($t =~ /^(?:-f|-F|--field|--raw-field)=(.*)$/s)  { $field = $1 }
      elsif ($t =~ /^(?:-f|-F|--field|--raw-field)$/ && defined $n) { $field = $n }
      if (defined $field && $field =~ /^body=(.*)$/s) {
        my $val = $1;
        if ($val =~ /^\@(.*)$/s) { push @bodies, read_body_file($1) }
        else                     { push @bodies, $val }
      }
      push @bodies, read_body_file($n) if $t eq q{--input} && defined $n;
      push @bodies, read_body_file($1) if $t =~ /^--input=(.*)$/s;
    }
  }

  push @found, scan($_) for grep { defined } @bodies;
}

my %seen; my @uniq = grep { !$seen{$_}++ } @found;
print join(q{, }, map { qq{#$_} } @uniq) if @uniq;
')

if [ -n "$FOUND" ]; then
  echo "Blocked: 投稿本文に Issue / PR の短縮参照 ${FOUND} がある。短縮形は同一リポジトリ内でしか解決されず、別リポを指すつもりだと無関係な Issue へ黙ってリンクされる。フル URL (https://github.com/<owner>/<repo>/issues/<n>) で書き直す。指す先が同一リポかどうかは本文の文脈から判断する (rules/github-writing.md)" >&2
  exit 2
fi

exit 0
