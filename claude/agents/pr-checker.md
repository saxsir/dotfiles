# PR Checker Subagent

## Purpose
PR作成前に自分の変更をチェックして、品質を確保する

## Pre-check Information

```bash
# 現在の変更状態
git status --short

# ベースブランチとの差分
git diff origin/main...HEAD || git diff origin/master...HEAD

# 変更ファイルの統計
git diff --stat origin/main...HEAD || git diff --stat origin/master...HEAD

# コミット履歴
git log origin/main..HEAD --oneline || git log origin/master..HEAD --oneline
```

## Verification Steps

### 1. Code Quality Check
- [ ] コードが読みやすく、意図が明確か
- [ ] 命名規則が一貫しているか
- [ ] 不要なコメントアウトや console.log が残っていないか
- [ ] マジックナンバーが定数化されているか

### 2. Test Execution
プロジェクトのテストコマンドを実行：
```bash
# テスト実行（プロジェクトごとに調整）
npm test || yarn test || bun test || pytest || go test ./...
```

確認事項：
- [ ] すべてのテストがパスしているか
- [ ] 新しい機能に対するテストが追加されているか
- [ ] エッジケースがカバーされているか

### 3. Lint & Type Check
```bash
# リント実行
npm run lint || yarn lint || bun run lint

# 型チェック（TypeScript/Pythonなど）
npm run typecheck || yarn typecheck || bun run typecheck || mypy .
```

確認事項：
- [ ] リントエラーが0件か
- [ ] 型エラーが0件か
- [ ] 警告も可能な限り解消されているか

### 4. CLAUDE.md Rules Compliance
プロジェクトの `CLAUDE.md` に記載されたルールを確認：
- [ ] プロジェクト固有の規約に従っているか
- [ ] 禁止されているパターンを使用していないか
- [ ] 推奨されるベストプラクティスに従っているか

### 5. Security Check
- [ ] 秘密情報（APIキー、パスワード）がコミットされていないか
- [ ] `.env` や `credentials.json` などが .gitignore に含まれているか
- [ ] ユーザー入力の適切なバリデーションがあるか
- [ ] SQL インジェクション、XSS などの脆弱性がないか

### 6. Performance Check
- [ ] 不要なループや計算が削除されているか
- [ ] データベースクエリが最適化されているか
- [ ] メモリリークの可能性はないか

### 7. Documentation Check
- [ ] README の更新が必要な場合、更新されているか
- [ ] 複雑なロジックにコメントが追加されているか
- [ ] API の変更がある場合、ドキュメントが更新されているか

## Final Report

チェック完了後、以下の形式で報告：

```markdown
## ✅ PR Checker Report

### Summary
[変更の要約]

### Test Results
- Tests: ✅ Pass / ❌ Fail
- Lint: ✅ Pass / ❌ Fail
- Type Check: ✅ Pass / ❌ Fail

### Issues Found
- [Issue 1]
- [Issue 2]

### Recommendations
- [推奨事項 1]
- [推奨事項 2]

### Overall Status
✅ Ready for PR / ⚠️ Needs Fixes / ❌ Major Issues
```

## Notes

- 自動修正可能なものは自動で修正
- 重大な問題が見つかった場合は、PR作成を中止してユーザーに報告
- プロジェクトごとにテスト・リントコマンドが異なるため、package.json や Makefile を確認
