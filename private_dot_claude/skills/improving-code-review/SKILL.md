---
name: improving-code-review
description: Triage human review comments on a PR (past or current) and append abstracted, source-linked checklist items to this repo's review checklist, so future reviews (via requesting-code-review-wrapper) catch the same class of issue. Invoke with an explicit PR number or URL, with no PR specified (defaults to the PR for the current branch), by describing which PR to find (e.g. by title/author/date), or right after finishing review fixes to ask whether to record what was learned.
---

# Improving the Review Checklist

Analyze human review comments on a PR and turn recurring, generalizable feedback into checklist entries stored at `<main-repo-root>/.claude/review-checklists/checklist.md`. Those entries get injected into future reviews by `requesting-code-review-wrapper`.

**Only human review comments count.** Per this user's standing instruction, AI reviewer comments (CodeRabbit, Copilot, etc.) are not the kind of feedback this skill is for — this is specifically about lessons from human reviewers.

## Four ways this gets invoked

**(a) Explicit PR number or URL** — user says something like "PR #372のレビューをチェックリストに反映して" or pastes a full URL like `https://github.com/<owner>/<repo>/pull/372`, or `/improving-code-review 372`.
→ If given a URL, extract `<owner>/<repo>` and the PR number from it directly (don't assume it's the repo in cwd — a pasted URL may point elsewhere; use `--repo <owner>/<repo>` from the URL for all `gh` calls below). If given a bare number, use the repo in cwd. Go to Step 1.

**(b) No PR specified** — user asks to update the checklist without naming a PR.
→ Resolve the PR for the current branch (`gh pr view --json number,url` with no argument, which defaults to the branch checked out in cwd). If there is no open PR for the current branch, ask the user which PR they mean.

**(c) User describes which PR to find, instead of giving a number/URL** — e.g. "さっきマージされた認証周りのPR" .
→ Use `gh pr list` / `gh search prs` with the criteria the user gave (author, title keywords, state, date range, repo) to find candidates:

```bash
gh pr list --repo <owner>/<repo> --state all --search "<keywords>" --json number,title,url,author,mergedAt
```

If exactly one match fits the description, confirm it with the user before proceeding ("PR #XXX 「<title>」で合っていますか？"). If multiple plausible matches exist, list them and ask the user to pick. Never silently guess when more than one PR could match.

**(d) Right after review-fix work, with no explicit invocation** — you (the agent) just finished fixing review comments on a PR in this same conversation, and the PR number and comment content are already in context.
→ Do NOT silently skip re-fetching. Ask the user: "このPRのレビュー内容をチェックリストに追記しますか？" If yes, proceed using the comment content already in context — but only if you actually fetched it via `gh` earlier in this conversation (i.e. you have the real comment text/URLs, not a paraphrase from memory). If you're not sure you have the exact original text and URL for each comment, re-fetch via Step 1 instead of trusting recollection.

## Step 1: Fetch PR comments

```bash
gh pr view <PR番号> --repo <owner>/<repo> --json number,url,title,body
~/.claude/skills/improving-code-review/scripts/fetch-review-comments.sh <owner> <repo> <PR番号>
```

`<owner>/<repo>` comes from the URL if one was given (case a), the resolved PR's repo (cases b/c/d) — never assume it's the repo in cwd without checking, since a pasted URL or a found PR can point to a different repo than the one you're currently in.

The fetch script already drops bot/AI authors (CodeRabbit, github-actions, dependabot, copilot, etc.) and groups replies into threads, with each comment trimmed to `author`/`created_at`/`body`/`html_url` (no `diff_hunk` dump) — use its output directly instead of raw `gh api .../comments`, which is mostly noise for triage. For PR-level review summaries, `gh api repos/<owner>/<repo>/pulls/<PR番号>/reviews` is still fine directly.

## Step 2: Resolve the checklist file path

The checklist always belongs to a specific local checkout's `.claude/review-checklists/checklist.md` — it is not fetched from GitHub, so it must live in a repo you actually have on disk.

**If the PR's `<owner>/<repo>` matches the repo in cwd** (the common case — cases b/c/d, and case a when the number/URL points at the repo you're already in): just run

```bash
~/.claude/skills/improving-code-review/scripts/resolve-checklist-path.sh
```

from cwd. This prints `<main-repo-root>/.claude/review-checklists/checklist.md`, resolved to the main checkout root even if cwd is a worktree.

**If the PR's `<owner>/<repo>` does NOT match the repo in cwd** (a URL/number for a different project than the one you're sitting in) — do not assume where to save it. Ask the user:

> このPRは `<owner>/<repo>` のもので、今いるリポジトリとは異なります。チェックリストの保存先はどちらにしますか？
>
> 1. 今作業しているリポジトリのchecklist（今の作業に役立つ観点として記録）
> 2. `<owner>/<repo>` のローカルチェックアウト（パスがあれば教えてください）

If the user picks option 2, run the same `resolve-checklist-path.sh` script but `cd` into the path they give first, so it resolves relative to that checkout's main root instead of cwd. If they don't have a local checkout of that repo, fall back to option 1 and say so.

Create the checklist file (and parent dir) if it doesn't exist yet.

## Step 3: Look at the actual diff context for each comment

The comments from Step 1 deliberately omit `diff_hunk` (it's the same few KB repeated on every reply in a thread). Before abstracting a comment, you still need to see the surrounding code it refers to, so resolve it in this order:

1. **Local checkout, if you have one open.** If the PR's branch is checked out in the current cwd, or in a worktree you already know about, just look at the file directly (`sed -n '<start>,<end>p' <path>`, or `git show <sha>:<path>` for the exact revision the comment was made against). This is the fastest path and needs no network call.

2. **Ask the user for the working directory, if resolving it isn't immediate.** If cwd doesn't obviously contain this PR's branch (e.g. you're in a different repo, or there's a worktree for it but you're not sure which), ask the user where the relevant checkout is rather than guessing or spending several tool calls hunting for it:

   > このPRのブランチのローカルチェックアウトはどこですか？（worktreeのパスなど）
   > Once given a path, `cd` there (or just target it directly) and look at `<path>:<line>` per option 1 above.

3. **Fall back to fetching the diff remotely, only if 1–2 don't resolve quickly.** This works regardless of cwd or worktree state — no local checkout needed:
   ```bash
   gh pr diff <PR番号> --repo <owner>/<repo>
   ```
   Grep the output for the comment's `path` to jump to the relevant hunk. For a single file, `gh api repos/<owner>/<repo>/contents/<path>?ref=<commit_id>` (using the comment's `commit_id`, not the fetch script's stripped-down output) also works if you just need that file's content at the reviewed revision.

Don't skip this step because a comment "seems clear" — the whole point of dropping `diff_hunk` from Step 1's output was to avoid paying for it on every comment, not to avoid ever looking at it. Pay that cost only for the comments you're actually about to abstract.

## Step 4: Abstract each comment into a generalizable check

For each human comment worth keeping, generalize it — don't store the literal PR-specific text.

**Abstraction example** (from this pattern's reference implementation):

- ❌ "`utils/format.py` を変更したが `lib/format.py` の同名関数が追随していなかった"
- ✅ "ユーティリティ関数を変更したとき、別ディレクトリに同名/類似役割のファイルがないか確認する"

Skip comments that are one-off, PR-specific, or already covered by an existing checklist entry (check the current file for near-duplicates before adding — if similar, extend the existing entry's text instead of adding a new one).

## Step 5: Propose before writing

Show the user the proposed entry/entries and ask for approval before touching the file:

```
【提案】以下のチェック項目を checklist.md に追加します:

---
### [YYYY-MM-DD] <短いタイトル>
**観点:** <抽象化したチェック内容>
**元コメント:** <GitHub review comment permalink>
---

承認しますか？（修正があればその内容をお知らせください）
```

Use the actual GitHub permalink to the review comment (from the `html_url` field in the API response, or construct `https://github.com/<owner>/<repo>/pull/<num>#discussion_r<comment_id>`), not just the PR URL — the reviewer needs to be able to jump straight to the original context.

## Step 6: Append to checklist.md

On approval, append using this format (create the file with a `# Review Checklist` header if new):

```markdown
### [YYYY-MM-DD] <短いタイトル>

**観点:** <抽象化したチェック内容>
**元コメント:** <GitHub permalink>
```

Do not rewrite or reorder existing entries. Report back a summary of what was added.

## Notes

- If the PR being analyzed turns out to be a plain feature addition with no missed-review-comment pattern (nothing generalizable), say so and skip writing — not every PR needs a checklist entry.
- Keep entries as generic patterns; never bake in a specific PR number or literal file name as the _check_ itself (the file name naturally appears in the source-comment context, that's fine — but the abstracted "観点" line should generalize beyond that one file).
