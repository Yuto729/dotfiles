---
name: check-tasks
description: Google Tasks確認スキル。タスクの一覧・確認が必要なときに使用する。「タスク確認して」「やること一覧」「期限近いタスクある？」などのリクエストで発動。gog CLIを使用。
---

# Check Tasks

gog tasksでGoogle Tasksを検索・確認する。

## アカウント

| 用途 | アカウント |
|---|---|
| デフォルト | `mitomi.yuuto2003@gmail.com` |
| 大学 | `mitomiyuto2003@g.ecc.u-tokyo.ac.jp` |
| 就活 | `yuto.mitomi0213@gmail.com` |

指定がなければデフォルトアカウントを使用。

## 手順

タスク取得は2ステップ:

1. `gog tasks lists list` でタスクリストIDを取得
2. 各リストIDに対して `gog tasks list <tasklistId>` を実行

## コマンド

```bash
# Step 1: タスクリスト一覧
gog tasks lists list --account=<ACCOUNT>

# Step 2: 特定リストのタスク一覧
gog tasks list <tasklistId> --account=<ACCOUNT>

# 完了済みも含める
gog tasks list <tasklistId> --show-completed --show-hidden --account=<ACCOUNT>

# 期限で絞り込み（RFC3339形式）
gog tasks list <tasklistId> --due-max=2026-02-07T00:00:00Z --account=<ACCOUNT>

# JSON出力（詳細情報が必要な場合）
gog tasks list <tasklistId> --json --account=<ACCOUNT>
```

## 既知のタスクリストID（デフォルトアカウント）

| リスト名 | ID |
|---|---|
| マイタスク | `MTI4MjcwNzczMDE3NjMxOTI0OTA6MDow` |
| 仕事 | `dWtDQlV3TnhrZkZ1ZmE5Vw` |

既知のIDがある場合は `lists list` をスキップして直接取得してよい。
複数リストがある場合は並列で取得する。

## 注意

- `source ~/.profile` は使用禁止（不要）
- タスクリストIDはBase64エンコードされた文字列。シェルでクォートする
- 結果は期限順に整理し、期限超過のタスクを強調して表示する
