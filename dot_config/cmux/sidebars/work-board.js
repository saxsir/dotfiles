// work-board: workspace を状態 lane (workspace の status) ごとに並べ、
// 各行に「何の作業か」(description = PR タイトル) を出す。
// agents-board を元にしている。agents-board は agent 単位の行だが、
// こちらは workspace 単位の行で、lane は agent の status でなく workspace.status。
//   cmux sidebar open work-board

const LANES = [
  { key: "needs-attention", label: "NEEDS YOU", color: "#FF9F0A", strong: true },
  { key: "working", label: "WORKING", color: "#0A84FF", strong: false },
  { key: "review", label: "REVIEW", color: "#BF5AF2", strong: false },
  { key: "todo", label: "TODO", color: "#7f7f7f", strong: false },
  { key: "done", label: "DONE", color: "#34C759", strong: false },
];

// agents[0].status の配色 (agents-board と同じ)
const DOT = {
  needs_input: "#FF9F0A",
  working: "#0A84FF",
  idle: "#34C759",
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

function repoName(w) {
  if (!w.directory) return "";
  const root = w.directory.split("/.claude/worktrees/")[0];
  return root.split("/").filter((p) => p).pop() ?? "";
}

const byLane = (key) => () =>
  (data.workspaces() ?? [])
    .filter((w) => w.status === key)
    .sort((a, b) => a.index - b.index);

function row(w, lane) {
  const strong = lane.strong;
  return HStack({ spacing: 8 }, [
    Circle({ size: 7 }).fill(() => DOT[w().agents?.[0]?.status] ?? DOT_NONE),
    VStack({ spacing: 1 }, [
      Text(() => headline(w()))
        .font(12).weight(strong ? "semibold" : "regular")
        .lineLimit(1).truncation("tail"),
      HStack({ spacing: 0 }, [
        Text(() => repoName(w())).font(10).color("tertiary").lineLimit(1).truncation("tail"),
        Text(() => (w().pr ? " · #" + w().pr.number : ""))
          .font(10).color("tertiary").lineLimit(1).fixedSize(),
        Text(() => (w().pr ? " " + w().pr.status : ""))
          .font(10).color(() => PR_COLOR[w().pr?.status] ?? "tertiary")
          .lineLimit(1).fixedSize(),
        Text(() => (w().latestAt ? " · " + fmt(epoch() - w().latestAt) : ""))
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

function laneSection(lane) {
  const items = byLane(lane.key);
  return VStack({ spacing: 3 }, [
    HStack({ spacing: 6 }, [
      Text(lane.label).font(10).weight("semibold")
        .color(() => (items().length && lane.strong ? lane.color : "tertiary")),
      Spacer(),
      Text(() => (items().length ? String(items().length) : ""))
        .font(10).monospaced().color("tertiary"),
    ]).paddingHorizontal(10),
    ForEach({ items, key: (w) => w.id }, (w) => row(w, lane)),
    Text(() => (items().length === 0 ? "—" : ""))
      .font(10).color("tertiary").paddingHorizontal(10),
  ]);
}

sidebar(() =>
  VStack({ spacing: 10 }, [
    Text("Work").font(14).weight("semibold").paddingHorizontal(10),
    ...LANES.map(laneSection),
    Spacer(),
  ]).paddingHorizontal(6),
  { surface: "glass" }
)
