// work-board: workspace をリポジトリ (directory の repo root) ごとに並べ、
// 各行に「何の作業か」(description = PR タイトル) を出す。
// 最上部の NEEDS YOU 欄は、agent が入力待ち (needs_input) か workspace.status が
// needs-attention の workspace を集める。該当が無いときは欄ごと出さない。
// パス表記の title (…/ / ~/ 始まり) を持つ workspace は元のフォルダ見出し (アンカー)
// とみなして行にせず、リポジトリ見出しのタップでそれを選択する。
// agents-board を元にしている。
//   cmux sidebar open work-board

const ORANGE = "#FF9F0A";

// agents[0].status の配色 (agents-board と同じ)
const DOT = {
  needs_input: ORANGE,
  working: "#0A84FF",
  idle: "#7f7f7f",
  ended: "#7f7f7f66",
};
const DOT_NONE = "#7f7f7f66";

const PR_COLOR = { open: "#34C759", merged: "#BF5AF2", closed: "#FF453A" };

const epoch = () => data.clock()?.epoch ?? 0;

function fmt(secs) {
  const s = Math.max(0, Math.floor(secs));
  if (s < 60) return s + "s";
  const m = Math.floor(s / 60);
  if (m < 60) return m + "m";
  return Math.floor(m / 60) + "h";
}

function headline(w) {
  const d = (w.description ?? "").split("\n")[0].trim();
  return d || w.agents?.[0]?.title || w.title;
}

const isAnchor = (w) => /^(…\/|\/|~\/)/.test(w.title ?? "");

const repoRoot = (w) =>
  w.directory ? w.directory.split("/.claude/worktrees/")[0] : "";

const repoName = (root) => root.split("/").filter((p) => p).pop() ?? "";

const needsYou = (w) =>
  w.status === "needs-attention" ||
  (w.agents ?? []).some((a) => a.status === "needs_input");

// リポジトリごとのセクション。順序は所属 workspace の最小 index、directory 無しは末尾。
const repoSections = computed(() => {
  const all = (data.workspaces() ?? []).slice().sort((a, b) => a.index - b.index);
  const map = new Map();
  for (const w of all) {
    const root = repoRoot(w);
    let sec = map.get(root);
    if (!sec) {
      sec = { id: root || "\u0000other", name: root ? repoName(root) : "other", other: !root, anchorId: null, rows: [] };
      map.set(root, sec);
    }
    if (isAnchor(w)) sec.anchorId = sec.anchorId ?? w.id;
    else sec.rows.push(w);
  }
  return [...map.values()]
    .filter((s) => s.rows.length > 0)
    .sort((a, b) => (a.other ? 1 : 0) - (b.other ? 1 : 0)); // Map は挿入順 = 最小 index 順
});

const needsItems = computed(() =>
  (data.workspaces() ?? [])
    .filter((w) => !isAnchor(w) && needsYou(w))
    .sort((a, b) => a.index - b.index)
);

function row(w, strong) {
  const pr = () => w().pr;
  return HStack({ spacing: 8 }, [
    Circle({ size: 7 }).fill(() => DOT[w().agents?.[0]?.status] ?? DOT_NONE),
    VStack({ spacing: 1 }, [
      Text(() => headline(w()))
        .font(12).weight(strong ? "semibold" : "regular")
        .lineLimit(1).truncation("tail"),
      HStack({ spacing: 0 }, [
        Text(() => (pr() ? "#" + pr().number : ""))
          .font(10).color("tertiary").lineLimit(1).fixedSize(),
        Text(() => (pr() ? " " + pr().status : ""))
          .font(10).color(() => PR_COLOR[pr()?.status] ?? "tertiary")
          .lineLimit(1).fixedSize(),
        Text(() => (w().latestAt ? (pr() ? " · " : "") + fmt(epoch() - w().latestAt) : ""))
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
    ForEach({ items: () => s().rows, key: (w) => w.id }, (w) => row(w, false)),
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
