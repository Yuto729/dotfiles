---
name: learning-journal
description: 会話のなかで得た技術的な学びを自動検知し、~/daily-life/work/knowledge/ にマークダウンとして記録する。また復習コマンドでランダムに1つ選んで復習を促す。「学びを記録」「knowledge追加」「復習」「review」などで起動。会話中にコンピュータ・サイエンス、設計パターン、アーキテクチャの判断、障害対策、運用知見などの学びが生まれたときにも自動的に起動する。
---

# Learning Journal

実装中の会話から学びを抽出・記録し、定期的に復習するためのスキル。

## 自動検知: 学びの記録

会話の中で以下のような学びが発生したときに、自動的にknowledgeへの記録を提案する。

**検知トリガー:**

- コンピュータ・サイエンスのトピックについて深く理解した時
- 設計パターンの比較・選定（例: Full Sync vs Delta Sync）
- 既存実装の調査から得た知見（例: リトライ戦略の違い）
- 障害モード・エラーハンドリングの議論
- パフォーマンスやスケーラビリティの判断
- 冪等性・トランザクション・整合性に関する議論
- 「なるほど」「理解した」等のユーザーの理解を示す発言

**記録フロー:**

1. 学びを検知したら「knowledgeに記録しますか？」と提案する
2. 承認を得たら `~/daily-life/work/knowledge/YYYY-MM-DD_<topic>.md` に記録する
3. 記録後、`~/daily-life/` リポジトリで git commit & push する

**ファイル形式:**

- パス: `~/daily-life/work/knowledge/YYYY-MM-DD_<topic>.md`
- topicはケバブケース英語（例: `retry-patterns`, `idempotency-patterns`）

**記録テンプレート:** [references/template.md](references/template.md) を参照して記録する。

**Git連携:**
記録後、以下を実行する:

```bash
cd ~/daily-life && git add work/knowledge/ && git commit -m "knowledge: <topic>" && git push
```

## 復習コマンド

「復習」「review」等のコマンドで起動する。

**フロー:**

1. `~/daily-life/work/knowledge/` 内のファイル一覧を取得する
2. ランダムに1つ選ぶ
3. 内容を読み込み、以下の形式で提示する:
   - タイトルと背景の要約（2-3行）
   - 「このプロジェクトでの採用箇所」のコード参照（ファイルパス:行番号）を最新のコードベースから再確認する
   - 理解度チェック: 関連する質問を1つ出す（例:「この場合はどのパターンを選ぶべき？」）
4. ユーザーの回答に対してフィードバックする
