// work-board: workspace をタスク単位のセクションに並べ、各行に「何の作業か」
// (description = PR タイトル) とリポジトリ名・PR・経過時間を出す。
// セクションのキーは行の 1 行目のテキストから決める。先頭の [タグ]、無ければ
// 最初の #番号、どちらも無ければ repo root の basename (directory 無しは other)。
// 最上部の NEEDS YOU 欄は、agent が入力待ち (needs_input) か workspace.status が
// needs-attention の workspace を集める。該当が無いときは欄ごと出さない。
// パス表記の title (…/ / ~/ 始まり) を持つ workspace は元のフォルダ見出し (アンカー)
// とみなして行にせず、リポジトリ見出しのタップでそれを選択する (タグ/番号の見出しは何もしない)。
// agents-board を元にしている。
//   cmux sidebar open work-board

const ORANGE = "#FF9F0A";

// Why-not: agents[0].status で working / idle を塗り分けない。cmux 0.65.2 では
// sidebar-state や hook セッション記録が idle でも agents[].status が working の
// まま残ることがあり、色が実態とずれる。ドットは NEEDS YOU と同じ判定だけ出す。
const DOT_HIDDEN = "#00000000";

const PR_COLOR = { open: "#34C759", merged: "#BF5AF2", closed: "#FF453A" };

const epoch = () => data.clock()?.epoch ?? 0;

function fmt(secs) {
  const s = Math.max(0, Math.floor(secs));
  if (s < 60) return s + "s";
  const m = Math.floor(s / 60);
  if (m < 60) return m + "m";
  const h = Math.floor(m / 60);
  return h >= 48 ? Math.floor(h / 24) + "d" : h + "h";
}

function headline(w) {
  const d = (w.description ?? "").split("\n")[0].trim();
  return d || w.agents?.[0]?.title || w.title;
}

const isAnchor = (w) => /^(…\/|\/|~\/)/.test(w.title ?? "");

const repoRoot = (w) =>
  w.directory ? w.directory.split("/.claude/worktrees/")[0] : "";

const repoName = (root) => root.split("/").filter((p) => p).pop() ?? "";

// BEGIN pure
const TAG_RE = /^\[([^\]]+)\]\s*/;

function sectionOf(text, directory) {
  const t = TAG_RE.exec(text);
  if (t) return { key: "tag:" + t[1], label: t[1], kind: "tag" };
  const n = /#(\d+)/.exec(text);
  if (n) return { key: "num:" + n[1], label: "#" + n[1], kind: "num" };
  const root = directory ? directory.split("/.claude/worktrees/")[0] : "";
  const name = repoName(root);
  if (name) return { key: "repo:" + name, label: name, kind: "repo" };
  return { key: "other", label: "other", kind: "other" };
}

// 見出しと同じ "#番号" を行テキストから外す。"(#4179)" "PR #4204" の形もまとめて消す。
function stripNum(text, label) {
  if (!label) return text;
  const n = label.slice(1);
  return text
    .replace(new RegExp("\\s*\\(?(?:PR\\s*)?#" + n + "(?!\\d)\\)?\\s*"), " ")
    .trim();
}
// END pure

const needsYou = (w) =>
  w.status === "needs-attention" ||
  (w.agents ?? []).some((a) => a.status === "needs_input");

// タスクごとのセクション。順序は所属 (アンカー以外の) workspace の最小 index、other は末尾。
const repoSections = computed(() => {
  const all = (data.workspaces() ?? []).slice().sort((a, b) => a.index - b.index);
  const map = new Map();
  for (const w of all) {
    if (isAnchor(w)) continue;
    const k = sectionOf(headline(w), w.directory);
    let sec = map.get(k.key);
    if (!sec) {
      sec = {
        id: k.key, name: k.label, other: k.kind === "other", anchorId: null, rows: [],
        num: k.kind === "num" ? k.label : null,
      };
      map.set(k.key, sec);
    }
    sec.rows.push(w);
  }
  for (const w of all) {
    if (!isAnchor(w)) continue;
    const name = repoName(repoRoot(w));
    const sec = name && map.get("repo:" + name);
    if (sec) sec.anchorId = sec.anchorId ?? w.id;
  }
  return [...map.values()].sort((a, b) => (a.other ? 1 : 0) - (b.other ? 1 : 0)); // Map は挿入順 = 最小 index 順
});

const needsItems = computed(() =>
  (data.workspaces() ?? [])
    .filter((w) => !isAnchor(w) && needsYou(w))
    .sort((a, b) => a.index - b.index)
);

function row(w, strong, num) {
  const pr = () => w().pr;
  const repo = (x) => repoName(repoRoot(x));
  return HStack({ spacing: 8 }, [
    Circle({ size: 7 }).fill(() => (needsYou(w()) ? ORANGE : DOT_HIDDEN)),
    VStack({ spacing: 1 }, [
      Text(() => stripNum(headline(w()).replace(TAG_RE, ""), num))
        .font(12).weight(strong ? "semibold" : "regular")
        .lineLimit(2).truncation("tail"),
      HStack({ spacing: 0 }, [
        Text(() => repo(w()))
          .font(10).color("tertiary").lineLimit(1).truncation("tail"),
        Text(() => (pr() ? (repo(w()) ? " · " : "") + "#" + pr().number : ""))
          .font(10).color("tertiary").lineLimit(1).fixedSize(),
        Text(() => (pr()?.status ? " " + pr().status : ""))
          .font(10).color(() => PR_COLOR[pr()?.status] ?? "tertiary")
          .lineLimit(1).fixedSize(),
        Text(() => (w().latestAt ? (repo(w()) || pr() ? " · " : "") + fmt(epoch() - w().latestAt) : ""))
          .font(10).monospaced().color("tertiary").lineLimit(1).fixedSize(),
      ]),
    ]),
    Spacer({ minLength: 0 }),
    Text(() => (w().unread > 0 ? String(w().unread) : ""))
      .font(10).weight("semibold").color("#FFFFFF")
      .paddingHorizontal(() => (w().unread > 0 ? 5 : 0))
      .background(() => (w().unread > 0 ? "#FF453A" : null))
      .cornerRadius(8)
      .fixedSize(),
  ])
    .paddingHorizontal(10).paddingVertical(6)
    .cornerRadius(8)
    .background(() => (w().selected ? "#7f7f7f40" : strong ? "#FF9F0A1a" : null))
    .hoverBackground(strong ? "#FF9F0A2e" : "#7f7f7f24")
    .frame({ maxWidth: "infinity" })
    .onTap(() => cmux("workspace.select", { workspace_id: w().id }));
}

function header(label, count, color, onTap) {
  const h = HStack({ spacing: 6 }, [
    Text(label).font(10).weight("semibold").color(color),
    Spacer(),
    Text(count).font(10).monospaced().color("tertiary"),
  ]).paddingHorizontal(10);
  return onTap ? h.onTap(onTap) : h;
}

function needsSection() {
  // 0 件のときは要素 0 の ForEach になり、見出しごと消える
  return ForEach(
    { items: () => (needsItems().length ? [{ id: "needs" }] : []), key: (x) => x.id },
    () =>
      VStack({ spacing: 3 }, [
        header("NEEDS YOU", () => String(needsItems().length), ORANGE),
        ForEach({ items: needsItems, key: (w) => w.id }, (w) => row(w, true)),
      ])
  );
}

function repoSection(s) {
  return VStack({ spacing: 3 }, [
    header(
      () => s().name,
      () => String(s().rows.length),
      "tertiary",
      () => s().anchorId && cmux("workspace.select", { workspace_id: s().anchorId })
    ),
    ForEach({ items: () => s().rows, key: (w) => w.id }, (w) => row(w, false, s().num)),
  ]);
}

sidebar(() =>
  VStack({ spacing: 10 }, [
    Text("Work").font(14).weight("semibold").paddingHorizontal(10),
    needsSection(),
    ForEach({ items: repoSections, key: (s) => s.id }, repoSection),
    Spacer(),
  ]).paddingHorizontal(6),
  { surface: "glass" }
)
