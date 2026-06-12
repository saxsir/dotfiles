# Brain-First (外部脳)

brain MCP (saxsir/brain-mcp) で外部脳に問い合わせられる。検索対象は auto-memory 全プロジェクト + 蒸留層 (`brain-mcp/brain/`)。

- **行動前に脳に聞く**: ユーザーの判断基準・好み・過去の文脈が関わる話題（設計判断、チーム運営、過去に考えたことの参照）では、回答や作業の前に `brain_ask` / `brain_search` で問い合わせる。
- `brain_ask` には question を分解した keyphrases を渡す。同義語・言い換えも並べると取りこぼしが減る。
- **gaps は脳に無い知識のシグナル**: 会話で補えたら memory への追記を提案する。`brain_neighbors` の dangling リンクも「あとで書く価値がある」の印。
- **蒸留層 `brain/` への追加は承認制**: 勝手に書かず「brain に入れますか?」と提案する。まとめての蒸留は `/brain-distill`。蒸留後も元の memory は消さない（短期層として残す）。
- セッションに brain MCP が無ければ無理に使わない（通常の memory recall で代替）。
