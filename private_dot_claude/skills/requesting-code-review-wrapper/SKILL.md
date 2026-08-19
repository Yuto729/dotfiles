---
name: requesting-code-review-wrapper
description: Use instead of superpowers:requesting-code-review when this repo may have a past-review checklist. Dispatches the same reviewer subagent but injects this repo's accumulated review checklist (from improving-code-review) into the review criteria. Works both for reviewing your own current local changes, and for reviewing an explicit PR by number/URL or by description. Unlike the upstream skill, does NOT fix issues by default — reports feedback and stops unless the user explicitly asks for a fix; all reviewed code lives in a worktree, temporary ones created just for a PR review are cleaned up afterward.
---

# Requesting Code Review (with repo checklist)

Thin wrapper around `superpowers:requesting-code-review`. Do not edit that skill or its `code-reviewer.md` template — this skill only adds one extra section to the dispatched prompt.

## Why this exists

`superpowers:requesting-code-review` is a shared plugin skill and shouldn't be edited locally. But real reviews from teammates surface repo-specific pitfalls (e.g. "this SQL file has a sibling that also needs updating") that a generic reviewer won't know to check. This wrapper keeps those checks in a per-repo file and injects them at review time without touching the upstream skill.

## Three ways this gets invoked

**(a) Reviewing your own current work** (the original use case) — no PR mentioned; you're reviewing local changes on a branch, e.g. after finishing a task in subagent-driven development, before merge, etc.
→ `BASE_SHA`/`HEAD_SHA` come from local git history as usual (`git rev-parse HEAD~1` / `origin/main` / etc. — per upstream skill). Go to Step 0.

**(b) Explicit PR number or URL** — user says something like "PR #372をレビューして" or pastes a full URL like `https://github.com/<owner>/<repo>/pull/372`.
→ If given a URL, extract `<owner>/<repo>` and the PR number from it directly (don't assume it's the repo in cwd). Fetch the PR's base/head SHAs:
```bash
gh pr view <PR番号> --repo <owner>/<repo> --json baseRefOid,headRefOid,headRefName,title,body
```
Use `baseRefOid` as `BASE_SHA` and `headRefOid` as `HEAD_SHA`. Go to Step 0.

**(c) User describes which PR to review, instead of giving a number/URL** — e.g. "さっき作ったPRをレビューして" or "認証周りのPRをレビューして".
→ Use `gh pr list` / `gh search prs` with the criteria the user gave (author, title keywords, state, date range, repo) to find candidates:
```bash
gh pr list --repo <owner>/<repo> --state all --search "<keywords>" --json number,title,url,author,mergedAt
```
If exactly one match fits the description, confirm it with the user before proceeding. If multiple plausible matches exist, list them and ask the user to pick. Never silently guess when more than one PR could match. Once resolved, proceed as in (b).

## Procedure

**0. Make sure the code to review is in a git worktree, not directly in the checkout you're sitting in.**
- Case (a): check `git worktree list` for an existing worktree for this branch/task first, and create one (`superpowers:using-git-worktrees`, or `git wt <name>` per this user's convention) if none exists. This worktree is the user's ongoing work — never delete it after the review.
- Case (b)/(c): check whether a worktree for the PR's `headRefName` already exists. If not, create a temporary one for the review, e.g. `git worktree add /tmp/review-pr-<PR番号> <headRefOid>` (or `git wt` if that fits the branch naming). Remember that this worktree was created solely for this review — after Step 6 completes (feedback has been reported), remove it: `git worktree remove <path>`. Do not remove a worktree that already existed before this invocation, and don't remove it before the user has seen the review feedback (they may still want to look at the code while it fixes are being decided — only clean up once you're about to end this review flow, not preemptively).

**1. Follow `superpowers:requesting-code-review` exactly** for steps: getting `BASE_SHA`/`HEAD_SHA` (per case a/b/c above), filling `{DESCRIPTION}` and `{PLAN_OR_REQUIREMENTS}`, and the overall dispatch/act-on-feedback loop. Read that skill now if you haven't already (`Skill` tool, name `requesting-code-review`).

**2. Resolve the checklist path before dispatching.** Run:

```bash
~/.claude/skills/requesting-code-review-wrapper/scripts/resolve-checklist-path.sh
```

This prints the absolute path to `<main-repo-root>/.claude/review-checklists/checklist.md`, correctly resolved even when the cwd is inside a git worktree (it always points at the main checkout, never the worktree).

**3. If the file exists, read it and append this section to the reviewer prompt**, right after the upstream template's `## What to Check` section (do not remove or reorder anything from the upstream template — just insert this block after it):

```
## Repo-Specific Checklist (from past human reviews)

This repo has accumulated the following checks from real review feedback.
Each item is an abstracted pattern, not the literal original comment — if
it's unclear whether an item applies to this diff, open the source link
and confirm the original context actually matches before applying it.
False-positive application of a stale/mismatched item is worse than
skipping it — when in doubt, skip and say why in your report.

[paste the full contents of checklist.md here]
```

**4. If the file does NOT exist, skip step 3 silently** — proceed with the plain upstream template. Do not treat a missing checklist as an error; most repos won't have one yet.

**5. Dispatch as usual** (per upstream skill: `general-purpose` subagent, template = upstream `code-reviewer.md` + the injected block above).

**6. Report the feedback — do NOT fix anything by default.** This overrides the upstream skill's "Fix Critical issues immediately" guidance. Present the Strengths/Issues/Recommendations/Assessment to the user as-is (with your own read on whether each Issue looks right, including pushback if the reviewer seems wrong) and stop. Only start implementing a fix if the user explicitly asks you to, either in this turn or as a standing instruction. Silently "just fixing" a Critical/Important issue after a review is the failure mode this step exists to block. If the user does ask for a fix, keep making it in the worktree from step 0 — do not remove it yet.

**Worktree cleanup** (case b/c only, per step 0): once the user has seen the feedback and isn't asking for further work in the temporary review worktree right now, remove it (`git worktree remove <path>`). If they asked for a fix and work is ongoing there, leave it until that work wraps up.

## After the review

If a checklist item led to a real catch, or if the review surfaced a gap the checklist should have covered, consider invoking `improving-code-review` to record it — see that skill for when to invoke.
