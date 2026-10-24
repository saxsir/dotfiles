# GitHub ワークフロー

PR を作ったらブラウザで開く (`gh pr view --web`)。

レビューコメントへの返信と thread の resolve は、投稿する前に文面と対象をユーザーに見せて承認を得る。dude の `pr-to-ready` のラウンド内も同じで、修正は判定役の accept に従って承認なしで進めるが、返信と resolve は止まって承認を取る。修正は過程の品質で Claude が持つ側、返信と resolve は対外的な締めでユーザーが持つ側だからだ ([[role-separation]])。
