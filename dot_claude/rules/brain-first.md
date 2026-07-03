# Brain-First

brain MCP (saxsir/brain-mcp) で全プロジェクトの auto-memory + 蒸留層 (`brain-mcp/brain/`) を検索できる。

- **行動前に脳に聞く**: ユーザーの判断基準・好み・過去の文脈が関わる話題 (設計判断、チーム運営、過去思考の参照) では、回答や作業の前に `brain_ask` / `brain_search` で問い合わせる。
- `brain_ask` には question を分解した keyphrases を渡す (同義語・言い換えも並べる)。
- **gaps は脳に無い知識のシグナル**: 会話で補えたら memory への追記を提案する。
- **蒸留層 `brain/` への追加は承認制**: 「brain に入れますか?」と提案。まとめての蒸留は `/brain-distill`。
- セッションに brain MCP が無ければ無理に使わない。
