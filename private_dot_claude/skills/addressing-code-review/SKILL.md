---
name: addressing-code-review
description: Address human review comments on a PR end-to-end — interpret each comment via superpowers:receiving-code-review, write a Plan file capturing quote/interpretation/response for every item, get human approval, then implement one commit per item (or per grouped items at the same location), and finally update the Plan with what actually happened and the commit URL. Invoke with an explicit PR number/URL, or with none to target the current branch's PR.
---

# Addressing Code Review

End-to-end workflow for responding to a PR's human review comments: interpret, plan, get approval, implement, and record — without ever replying to the human reviewer yourself.

**Never reply to human review comments.** Per this user's standing instruction, only the user replies to human reviewers. This skill produces a Plan file and commits; it does not post any GitHub comment or reply. (AI reviewer comments — CodeRabbit, Copilot, etc. — are not in scope for this restriction, but this skill is about human review anyway.)

## Invocation

- **Explicit PR number or URL**: use that PR. If a URL, extract `<owner>/<repo>` and the number from it — don't assume it's the repo in cwd.
- **No PR given**: resolve the PR for the current branch via `gh pr view --json number,url` with no argument.
- If neither resolves, ask the user which PR to target.

## Step 1: Fetch unresolved human review comments

```bash
gh pr view <PR番号> --repo <owner>/<repo> --json number,url,title,body
~/.claude/skills/addressing-code-review/scripts/fetch-review-comments.sh <owner> <repo> <PR番号>
```

The fetch script replaces raw `gh api .../pulls/<n>/comments` — that endpoint dumps every field (`diff_hunk`, `node_id`, `_links`, `reactions`, ...) and every bot comment (CodeRabbit etc.) for every single comment, which is mostly noise for this task. The script already:
- drops bot/AI authors (CodeRabbit, github-actions, dependabot, copilot, etc.) — pass `--include-bots` only if the user explicitly wants those too
- groups replies into threads by `in_reply_to_id`, sorted by file path then line
- keeps only `author`, `created_at`, `body`, `html_url` per comment (no diff_hunk dump)

Output is JSON: an array of `{path, line, root_comment_id, html_url, comments: [...]}`.

Still check thread resolution state separately if needed — this script does not filter out already-resolved threads (that needs `gh api graphql`, since the REST comments endpoint doesn't expose `isResolved`). If resolution status matters for this PR, query it and cross-reference by `root_comment_id`.

For the PR-level review summaries (not inline comments), still use `gh api repos/<owner>/<repo>/pulls/<PR番号>/reviews` directly — those are rarely large enough to need trimming.

## Step 2: Interpret each item via `receiving-code-review`

Before writing anything to the Plan, invoke `superpowers:receiving-code-review` and follow its response pattern for every comment: read the full comment without reacting, restate the requirement, verify against the actual codebase (grep for usage, check for existing reasons the code is the way it is, etc.), and decide whether the feedback is technically sound for this codebase.

This step happens BEFORE the Plan is written — the Plan records the outcome of this interpretation, not a first impression.

If a comment is unclear even after investigation, note the ambiguity in the Plan and flag it for the user rather than guessing.

## Step 3: Resolve the repo root and write the Plan file

```bash
~/.claude/skills/addressing-code-review/scripts/resolve-repo-root.sh
```

Resolves to the main checkout root even from inside a worktree. The Plan file lives at:

```
<repo-root>/.claude/review-plans/pr-<PR番号>.md
```

If this file already exists (re-running on the same PR after new comments arrived), append new items rather than overwriting existing ones — existing items that already have a "実施結果" section are done; leave them untouched.

**Plan file format** — one section per review item:

```markdown
# Review Plan: PR #<番号> <タイトル>

<PR URL>

## Item 1: <一言要約>

**レビューコメント:**
> <指摘されているコードスニペット（あれば）>
> <指摘全文>

（コメント: <GitHub permalink>）

**解釈:**
<receiving-code-reviewの検証結果を踏まえた解釈。技術的に妥当か、押し戻すべき点があるか>

**対応方針:**
<直す場合: どのファイルのどこをどう直すか
直さない場合: なぜ対応しないか、ユーザーに何を伝えるべきか（返信文言の下書きでも可 — 実際の返信はユーザーが行う）>

---

## Item 2: ...
```

Group two or more items into one "対応方針" block (with a shared commit) when they point at the same location and a combined fix is more natural — say so explicitly in the plan text (e.g. "Item 2, 3 はまとめて対応する").

## Step 4: Stop and get human approval

Present the Plan file to the user and stop. Do not proceed to implementation until the user approves it or requests changes. If they request changes, edit the Plan and ask again.

## Step 5: Implement, one commit per item (or per group)

For each item/group in the approved Plan:
1. Make the fix.
2. Verify it (run tests/build as appropriate).
3. Commit with a message describing the fix (not "address review comment #N" — describe what changed).
4. Get the commit SHA/URL.

If an item truly can't be isolated into its own commit (e.g. it's entangled with another change), it's fine to split further or combine — but default to one item = one commit.

## Step 6: Update the Plan with actual outcomes

After implementing, edit the Plan file — append to each item's section:

```markdown
**実施結果:**
方針通り。commit: <commit URL>
```

or, if what was actually done differs from the planned approach:

```markdown
**実施結果:**
実際はどうしたか: <実際の対応内容>。commit: <commit URL>
```

Do this for every item covered in this run, immediately after its commit lands — don't batch all the updates to the very end in case the session is interrupted partway through.

## Notes

- This skill never posts to GitHub. Replying to the reviewer is the user's job.
- If an item's resolution is "don't fix, explain why," still record that in the Plan (対応方針 states the reasoning; 実施結果 confirms no code change was made) — this is not skipped, just a different kind of resolution.
