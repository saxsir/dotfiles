# 並列化と Subagent

タスクを受けたら、最初に「**並列化できる subtask は何か**」「**subagent に逃がして main context を空けられる仕事はないか**」を検討してから動く。default は **subagent 優先 / 並列優先**。

## 判断基準

| 状況 | やり方 |
|------|--------|
| 互いに独立な 2 つ以上のタスク | Agent tool を 1 message 内に複数並べて並列 dispatch（独立な search、複数シナリオ評価、複数モデル比較など） |
| 大量探索・grep・解析（3 query 以上の規模） | `Explore` / `general-purpose` subagent に投げ、main は要約だけ受け取る |
| バイアスを排した評価（自分の生成物の検証、skill / prompt の評価） | 新規 subagent を立てる。自分で再読して評価しない |
| 長時間バッチ（Bash の 10 分上限を超える、複数 repo への一括処理など） | subagent dispatch か `run_in_background` + `Monitor` |

## 避けるべき

- 直列依存（前タスクの結果が次タスクの入力）を無理に並列化する
- 1 step / short lookup を subagent に投げる（overhead が成果に見合わない）
- subagent と main で同じ作業を二重に走らせる

## Why

- main context は有限資源。大量出力を直接受けると関係ないノイズで判断力が落ちる
- 自己レビューはバイアスがかかる。評価者と生成者の context を分ける
- 並列化を最初に考えないと、結局直列で回して時間を浪費する（後から見ると並列化できた、が頻発する）
