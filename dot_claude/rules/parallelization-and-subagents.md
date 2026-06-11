# 並列化と Subagent

タスクを受けたら最初に「並列化できる subtask」「subagent に逃がして main context を空けられる仕事」を検討する。default は subagent 優先 / 並列優先。

- 独立な subtask は subagent に委譲し、待たずに作業を続ける。脱線・コンテキスト不足の subagent には介入する。
- 大量探索・grep・解析は `Explore` / `general-purpose` に投げ、main は要約だけ受け取る。
- 自己生成物の評価は別 subagent を立てる（評価者と生成者の context を分けてバイアスを排す）。
- 委譲プロンプトは自己完結させる: 対象ファイルパス・従うべき規約・観測可能な完了条件・検証コマンドを含める（@rules/verification-by-declaration.md の宣言を委譲時にも適用する）。
- 長時間タスクでは完了時だけでなく途中でも、fresh context の subagent に仕様照合の検証を定期的にさせる（自己批評で済ませない）。
- 避ける: 直列依存の無理な並列化、1 step / short lookup の委譲（overhead が成果に見合わない）。
