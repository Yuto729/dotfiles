---
name: check-calendar
description: Google Calendar確認スキル。予定の確認・検索が必要なときに使用する。「今日の予定は？」「今週のスケジュール」「来週の予定確認して」などのリクエストで発動。gog CLIを使用。
---

# Check Calendar

gog calendar eventsでGoogle Calendarの予定を検索・確認する。

## アカウント

| 用途 | アカウント |
|---|---|
| デフォルト | `mitomi.yuuto2003@gmail.com` |
| 大学 | `mitomiyuto2003@g.ecc.u-tokyo.ac.jp` |
| 就活 | `yuto.mitomi0213@gmail.com` |

指定がなければデフォルトアカウントを使用。

## コマンド

```bash
# 直近の予定（デフォルト10件）
gog calendar events --account=<ACCOUNT>

# 今日の予定
gog calendar events --today --account=<ACCOUNT>

# 明日の予定
gog calendar events --tomorrow --account=<ACCOUNT>

# 今週の予定
gog calendar events --week --account=<ACCOUNT>

# N日間の予定
gog calendar events --days=7 --account=<ACCOUNT>

# 日付範囲を指定
gog calendar events --from=2026-02-03 --to=2026-02-10 --account=<ACCOUNT>

# キーワードで検索
gog calendar events --query="MTG" --account=<ACCOUNT>

# 件数を増やす
gog calendar events --max=30 --account=<ACCOUNT>
```

## 注意

- `source ~/.profile` は使用禁止（不要）
- `--today`, `--tomorrow`, `--week` はタイムゾーン対応
- 結果は時系列で整理し、日付・時間・タイトルをテーブル形式で表示する
