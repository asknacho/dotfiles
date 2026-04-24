---
name: git-rewrite-reviewable
description: Backup current branch and rebuild its history incrementally against a base (default main) with clear, review-friendly commits
license: MIT
compatibility: opencode
metadata:
  audience: maintainers, contributors, release engineers
  workflow: github, gitlab, azure-devops
---

## What I do

- Create a **backup copy** of your current branch (local and optional remote).
- Reset your branch against a base (default `main`) to start from a clean slate.
- Rebuild history **incrementally** using logical groups (by topic, folder, feature), with **clear, Conventional Commit–style messages**.
- Preserve authorship attribution (via `cherry-pick -x`), or re-author if requested.
- Handle merges, renames, binary changes, submodules, and LFS-aware diffs where applicable.
- Verify that the rebuilt branch is equivalent to the original branch’s net changes (via `git range-diff` and/or tests).
- Provide **safe push** options (`review/*` branch) or **opt-in** `--force-with-lease` updates.

## When to use me

Use this when your branch history is noisy (WIP, accidental merges, noisy fixups), and you want to **present a clean, readable sequence of commits** for code review—without losing any work. Ideal before opening a PR/MR or just before release hardening.

## What I need from you (inputs)

- **Base branch** (default: `main`): e.g., `main`, `develop`, `release/2.x`, or a tag/commit.
- **Strategy** (optional): `cherry-pick` (preserve original commits) or `soft-reset` (re-stage changes into new commits).
- **Grouping preference** (optional): by folder/module, by feature, or by original commit topics.
- **Commit message style** (optional): Conventional Commits (`feat/fix/docs/refactor/...`) or custom template.
- **Output branch** (optional): rewrite in-place (with `--force-with-lease`) or push to `review/<branch>` (default).
- **Dry run** (optional): produce a plan and commands without changing your repo.

## How I work (step-by-step)

1. **Preflight & Safety**
   - Ensure a **clean working tree**. If dirty, I’ll stage/stash as needed (configurable).
   - Detect current branch: `BR=$(git rev-parse --abbrev-ref HEAD)`.
   - Determine **base** (default `main`) and fetch latest: `git fetch --all --prune`.

2. **Backup**
   - Create backup: `git branch backup/${BR}-$(date +%Y%m%d-%H%M%S)` and (optional) `git push -u origin backup/${BR}-...`.
   - (Recovery instruction is provided below; you can always `git checkout backup/...`.)

3. **Assess the Delta**
   - Compute diff range: `${BASE}..${BR}`.
   - Inventory changes: files added/modified/renamed/deleted; detect merges/binaries/submodules.
   - Suggest **grouping plan** (by module, feature, or commit topics) sized for review (e.g., ~100–300 LOC per commit).

4. **Choose a Rewrite Strategy**

   **A) Cherry-pick (preserves original commits & authorship)**
   - Create a clean staging branch: `git checkout -b review/${BR} ${BASE}`.
   - Re-apply commits in a **curated order**:
     - Use `git cherry-pick --keep-redundant-commits -x <commit>` for exact replays.
     - Use `--no-commit` to aggregate several related commits before producing a single, clear commit.
     - Squash noisy fixups via `--fixup/--squash` + `rebase -i --autosquash` as needed.
     - Edit messages to clear, review-friendly summaries; note breaking changes and migrations.
   - For merge commits: break into topical commits or cherry-pick with `-m 1` and resolve carefully.

   **B) Soft Reset (re-stage into brand-new commits)**
   - Start from the base: `git checkout ${BR} && git reset --soft ${BASE}` (or do this on `review/${BR}`).
   - Use **patch mode** to build clear commits:
     - `git add -p` (or `git restore -p --staged`) to pick hunks per logical topic.
     - Commit with strong messages (see template below).
     - Repeat until all changes are committed in coherent, reviewable steps.

5. **Conflict Handling**
   - Resolve file conflicts as they appear.
   - For renames/moves, rely on Git detection (`-M`) and verify histories.
   - For binaries/submodules/LFS, add whole-file commits with explicit messages.

6. **Verification**
   - Check equivalence:
     - `git range-diff ${BASE}...backup/${BR} ${BASE}...review/${BR}` (or new branch).
     - Run tests/build/lint (if provided) to ensure no functional regressions.
   - Confirm commit messages meet policy (Conventional Commits or your template).

7. **Publish**
   - Default (safe): push to new branch: `git push -u origin review/${BR}` and open PR/MR.
   - Optional (in-place): **only if requested**, update original branch with `git push --force-with-lease origin ${BR}`.

8. **Recovery**
   - If anything goes wrong: `git checkout ${BR} && git reset --hard backup/${BR}-<timestamp>` (or `git reflog`).

## Output format

- **Plan Overview**
  - Base, current branch, chosen strategy, and the grouping plan (topics & files per commit).
- **Commit Plan (ordered)**
  - For each planned commit: Title → Scope → Rationale → Files/paths → Estimated LOC.
- **Ready-to-run Commands**
  - Exact `git` commands for backup, rewrite, conflict resolution checkpoints, verification, and publish.
- **Commit Message Drafts**
  - Clear summaries with body, scope, breaking changes, and migration notes.
- **Verification Report**
  - `range-diff` summary and (optional) test/build results.
- **Recovery Instructions**
  - How to restore from backup or reflog.

## Commit message template (recommended)