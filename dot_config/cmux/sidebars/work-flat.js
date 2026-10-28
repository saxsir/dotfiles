// work-flat: workspace を cmux 本体と同じ index 順の 1 本のリストで出す。
// 並べ替え・抜き出しをしないので、nextSidebarTab の移動順と画面の順が一致する。
// 見出しは cmux の workspace group の name と所属件数。index 順で group が変わる
// 位置に出す。group に属さない workspace が group の後に続くときだけ薄い
// "ungrouped" 見出しを出し、先頭の連続には出さない。
// 入力待ち (needs_input / needs-attention) の行はオレンジのドットと強調背景、
// 動いている agent がいない行は薄く出す。最上部の "Work" の横に入力待ちの件数を出す。
// work-board を元にしている。
//   cmux sidebar select work-flat

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

const isPath = (t) => /^(…\/|\/|~\/)/.test(t ?? "");

const repoRoot = (w) =>
  w.directory ? w.directory.split("/.claude/worktrees/")[0] : "";

const repoName = (root) => root.split("/").filter((p) => p).pop() ?? "";

// Claude セッションを閉じると title がパス表記に戻るので、ブラウザ等のタブ名、
// それも無ければリポジトリ名で代える。
function headline(w) {
  const d = (w.description ?? "").split("\n")[0].trim();
  if (d) return d;
  if (w.agents?.[0]?.title) return w.agents[0].title;
  if (!isPath(w.title)) return w.title;
  const tab = (w.tabs ?? []).find((t) => t.title && !isPath(t.title));
  return tab?.title || repoName(repoRoot(w)) || w.title;
}


const needsYou = (w) =>
  w.status === "needs-attention" ||
  (w.agents ?? []).some((a) => a.status === "needs_input");

const parked = (w) =>
  !needsYou(w) && !(w.agents ?? []).some((a) => a.status !== "ended");

const entries = computed(() => {
  const all = (data.workspaces() ?? []).slice().sort((a, b) => a.index - b.index);
  const groups = new Map((data.groups() ?? []).map((g) => [g.id, g]));
  const gid = (w) => (w.group && groups.has(w.group) ? w.group : null);
  const out = [];
  let prev;
  let hdr = null;
  all.forEach((w, i) => {
    const g = gid(w);
    if (i === 0 || g !== prev) {
      if (g) {
        hdr = { id: "h:" + i, kind: "header", label: groups.get(g).name, count: 0, total: all.filter((x) => gid(x) === g).length };
        out.push(hdr);
      } else if (i > 0) {
        hdr = { id: "h:" + i, kind: "header", label: "ungrouped", count: 0, total: null };
        out.push(hdr);
      } else {
        hdr = null;
      }
    }
    if (hdr && hdr.total === null) hdr.count++;
    out.push({ id: "w:" + w.id, kind: "ws", ws: w });
    prev = g;
  });
  return out;
});

const needsCount = computed(() => (data.workspaces() ?? []).filter(needsYou).length);


function row(w) {
  const pr = () => w().pr;
  const repo = (x) => repoName(repoRoot(x));
  return HStack({ spacing: 8 }, [
    Circle({ size: 7 }).fill(() => (needsYou(w()) ? ORANGE : DOT_HIDDEN)),
    VStack({ spacing: 1 }, [
      Text(() => headline(w()))
        .font(12).weight(() => (needsYou(w()) ? "semibold" : "regular"))
        .lineLimit(2).truncation("tail"),
      Text(() => w().progress?.label ?? "")
        .font(10).color("tertiary").lineLimit(1).truncation("tail"),
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
    .background(() => (w().selected ? "#7f7f7f40" : needsYou(w()) ? "#FF9F0A1a" : null))
    .hoverBackground(() => (needsYou(w()) ? "#FF9F0A2e" : "#7f7f7f24"))
    .frame({ maxWidth: "infinity" })
    .opacity(() => (parked(w()) ? 0.6 : 1))
    .onTap(() => cmux("workspace.select", { workspace_id: w().id }));
}

function header(label, count, color) {
  return HStack({ spacing: 6 }, [
    Text(label).font(10).weight("semibold").color(color),
    Spacer(),
    Text(count).font(10).monospaced().color("tertiary"),
  ]).paddingHorizontal(10);
}

sidebar(() =>
  VStack({ spacing: 3 }, [
    HStack({ spacing: 6 }, [
      Text("Work").font(14).weight("semibold"),
      Text(() => (needsCount() > 0 ? "NEEDS YOU " + needsCount() : ""))
        .font(10).weight("semibold").color(ORANGE),
      Spacer(),
    ]).paddingHorizontal(10).paddingVertical(4),
    ForEach({ items: entries, key: (e) => e.id }, (e) =>
      VStack({ spacing: 0 }, [
        ForEach(
          { items: () => (e().kind === "header" ? [e()] : []), key: (x) => x.id },
          (h) => header(() => h().label, () => String(h().total ?? h().count), "tertiary").paddingVertical(3)
        ),
        ForEach(
          { items: () => (e().kind === "ws" ? [e()] : []), key: (x) => x.id },
          (x) => row(() => x().ws)
        ),
      ])
    ),
    Spacer(),
  ]).paddingHorizontal(6),
  { surface: "glass" }
)
