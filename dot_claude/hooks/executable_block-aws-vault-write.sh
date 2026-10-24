#!/bin/bash
# aws-vault / avt の実行を readonly profile (-readonly サフィックス) に限定する PreToolUse フック
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

echo "$CMD" | grep -qiE 'aws-vault|(^|[^a-zA-Z0-9_-])avt([^a-zA-Z0-9_-]|$)' || exit 0

# コマンド位置 (区切りの先頭。代入と command/exec/time/env は読み飛ばす) にある呼び出しだけを
# 検査する。引数・引用符の中・heredoc の本文に出る aws-vault は実行されないので見ない。
# $(...) と `...` は引用符の中でも実行されるので、中身を別のコマンドとして検査する。
# Why-not: シェルの完全な構文解析ではない。eval / xargs / sh -c '...' の文字列や、変数に
# 入れたコマンド名で呼ぶ形は検出できない。本 hook の脅威モデルは Claude が正常動作で誤って
# 非 readonly profile を選ぶ事故の防止であり、難読化・injection は対象外。
# Why-not: `aws-vault exec x-readonly -- sh -c 'aws-vault exec prod -- ...'` のような入れ子の
# 内側は検査しない。内側の aws-vault は keychain を自分で読むので外側の profile では縛られないが、
# aws-vault 自身が AWS_VAULT の設定された subshell 内での実行を拒否する。これを越えるには
# AWS_VAULT を明示的に unset する必要があり、それは上の対象外の難読化に当たる。
IFS= read -r -d '' classify_pl <<'PERL'
use strict;
use warnings;

my $sq = chr(39);

sub strip_heredocs {
  my ($s) = @_;
  my (@out, @pending);
  for my $line (split /\n/, $s, -1) {
    if (@pending) {
      my ($delim, $tabs) = @{ $pending[0] };
      my $cmp = $line;
      $cmp =~ s/^\t+// if $tabs;
      shift @pending if $cmp eq $delim;
      next;
    }
    push @out, $line;
    while ($line =~ /<<(?!<)(-?)[ \t]*(["$sq]?)([A-Za-z0-9_]+)\2/g) {
      push @pending, [ $3, $1 eq '-' ];
    }
  }
  return join("\n", @out);
}

sub parse {
  my ($s, $segs) = @_;
  my @c = split //, $s;
  my $n = @c;
  my (@words, $word);
  my $dyn = 0;
  my $i = 0;

  my $flush_word = sub {
    push @words, { v => $word, dyn => $dyn } if defined $word;
    $word = undef;
    $dyn = 0;
  };
  my $flush_seg = sub {
    $flush_word->();
    push @$segs, [@words] if @words;
    @words = ();
  };
  my $substitute = sub {
    my ($start, $kind) = @_;
    my $j = $start;
    if ($kind eq 'paren') {
      my $depth = 1;
      while ($j < $n) {
        $depth++ if $c[$j] eq '(';
        $depth-- if $c[$j] eq ')';
        last if $depth == 0;
        $j++;
      }
    } else {
      $j++ while $j < $n && $c[$j] ne '`';
    }
    parse(substr($s, $start, $j - $start), $segs);
    $word = '' unless defined $word;
    $word .= '$';
    $dyn = 1;
    return $j + 1;
  };

  while ($i < $n) {
    my $ch = $c[$i];
    my $next = $i + 1 < $n ? $c[$i + 1] : '';
    if ($ch eq '\\') {
      $word = '' unless defined $word;
      $word .= $next unless $next eq "\n";
      $i += 2;
    } elsif ($ch eq $sq) {
      my $j = index($s, $sq, $i + 1);
      $j = $n if $j < 0;
      $word = '' unless defined $word;
      $word .= substr($s, $i + 1, $j - $i - 1);
      $i = $j + 1;
    } elsif ($ch eq '"') {
      $word = '' unless defined $word;
      $i++;
      while ($i < $n && $c[$i] ne '"') {
        my $d = $c[$i];
        my $dn = $i + 1 < $n ? $c[$i + 1] : '';
        if ($d eq '\\' && $dn ne '') {
          $word .= $dn;
          $i += 2;
        } elsif ($d eq '$' && $dn eq '(') {
          $i = $substitute->($i + 2, 'paren');
        } elsif ($d eq '`') {
          $i = $substitute->($i + 1, 'tick');
        } else {
          $dyn = 1 if $d eq '$';
          $word .= $d;
          $i++;
        }
      }
      $i++;
    } elsif ($ch eq '$' && $next eq '(') {
      $i = $substitute->($i + 2, 'paren');
    } elsif ($ch eq '`') {
      $i = $substitute->($i + 1, 'tick');
    } elsif ($ch eq ' ' || $ch eq "\t") {
      $flush_word->();
      $i++;
    } elsif ($ch eq '<' || $ch eq '>' || ($ch eq '&' && $next eq '>')) {
      my $op = '';
      if (defined $word && !$dyn && $word =~ /^\d+$/) {
        $op = $word;
        $word = undef;
      } else {
        $flush_word->();
      }
      while ($i < $n && $c[$i] =~ /[<>&]/) {
        $op .= $c[$i];
        $i++;
      }
      push @words, { v => $op, redir => 1 };
    } elsif ($ch =~ /[;&|()\n]/) {
      $flush_seg->();
      $i++;
    } else {
      $dyn = 1 if $ch eq '$';
      $word = '' unless defined $word;
      $word .= $ch;
      $i++;
    }
  }
  $flush_seg->();
}

my @segs;
parse(strip_heredocs($ENV{HOOK_CMD} // ''), \@segs);

my $profile_re = qr/^[A-Za-z0-9_.-]+-readonly$/i;

for my $seg (@segs) {
  my @w;
  for (my $k = 0; $k < @$seg; $k++) {
    if ($seg->[$k]{redir}) {
      $k++;
      next;
    }
    push @w, $seg->[$k];
  }

  my $k = 0;
  while ($k < @w) {
    my $v = $w[$k]{v};
    if ($v =~ /^[A-Za-z_][A-Za-z0-9_]*=/ || $v =~ /^(if|then|elif|else|do|while|until|!|\{|\})$/) {
      $k++;
      next;
    }
    if ($v =~ /^(command|exec|time|env)$/) {
      my $wrapper = $v;
      $k++;
      while ($k < @w && $w[$k]{v} =~ /^-/) {
        my $opt = $w[$k]{v};
        if ($wrapper eq 'command' && $opt =~ /^-[A-Za-z]*[vV]/) {
          $k = @w;
          last;
        }
        $k++;
        $k++ if ($wrapper eq 'env' && $opt =~ /^-[uC]$/) || ($wrapper eq 'exec' && $opt eq '-a');
      }
      next;
    }
    last;
  }
  next if $k >= @w;

  my $prog = lc $w[$k]{v};
  $prog =~ s{.*/}{};
  next unless $prog eq 'aws-vault' || $prog eq 'avt';
  my @args = @w[ $k + 1 .. $#w ];

  if ($prog eq 'avt') {
    next if @args && !$args[0]{dyn} && $args[0]{v} =~ $profile_re;
    print "deny\n";
    exit 0;
  }

  my $sub = @args ? lc $args[0]{v} : '';
  next if $sub =~ /^(list|--version|--help)$/;
  if ($sub =~ /^(add|remove|rm|rotate|clear)$/) {
    print "manage\n";
    exit 0;
  }
  if ($sub =~ /^(exec|login|export)$/) {
    my $p = 1;
    $p++ while $p < @args && $args[$p]{v} =~ /^--?[A-Za-z0-9-]+=.+$/;
    next if $p < @args && !$args[$p]{dyn} && $args[$p]{v} =~ $profile_re;
  }
  print "deny\n";
  exit 0;
}
print "allow\n";
PERL
verdict=$(HOOK_CMD="${CMD}" perl -e "${classify_pl}")

# fail-closed: 変数展開・コマンド置換・値が分離したフラグ (--duration 1h) は profile 名を静的に
# 確定できないため許可しない (フラグは --opt=value 形式で書く)。判定スクリプト自体が失敗した
# ときもブロックする。
case "${verdict}" in
  allow)
    exit 0
    ;;
  manage)
    echo "Blocked: aws-vault の credential 管理 (add/remove/rotate/clear) は Claude から実行しない。必要ならユーザーが '! <command>' で手動実行する: $CMD" >&2
    exit 2
    ;;
  *)
    echo "Blocked: aws-vault / avt は '-readonly' で終わる profile 名 (リテラル) でのみ実行できる: $CMD" >&2
    echo "対処: profile を '<name>-readonly' に書き換える。フラグは '--opt=value' 形式で profile の前に置く。書き込みが必要な操作はユーザーが '! <command>' で手動実行する" >&2
    exit 2
    ;;
esac
