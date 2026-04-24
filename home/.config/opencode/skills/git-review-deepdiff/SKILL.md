---
name: git-review-deepdiff
description: Request a thorough, step-by-step incremental code review of a branch vs a base (default main)
license: MIT
compatibility: opencode
metadata:
  audience: maintainers, reviewers, contributors
  workflow: github, gitlab, azure-devops
---

## What I do

- Detect the current branch and compare it against a base (defaults to `main` unless specified).
- Build a change inventory (files, diffs, churn, renames/moves) in manageable chunks to avoid overload.
- Perform an **incremental review** (commit-by-commit and/or topic-by-topic) with clear, structured findings.
- Assess correctness, API/contract compatibility, security, performance, concurrency, reliability, and readability.
- Flag **breaking changes** and risky hotspots; call out database migrations and infra/config changes.
- Evaluate tests around the changed surface; suggest missing unit/integration/e2e tests and edge cases.
- Propose **ready-to-paste review comments**, suggested refactors, and code snippets.
- Generate a **PR body** draft and a **follow-up checklist** (risk, owner, and priority).
- Provide reproducible **git commands** to explore the change locally.
- Ask clarifying questions only when **base branch or scope is unclear** (no step-by-step confirmations).

## When to use me

Use this when you want a deep, structured pre-PR or pre-merge review; when inheriting a large branch; or when you need a systematic read for correctness, security, and maintainability across many files.  
Ask clarifying questions if the base branch, scope (paths), or priorities (e.g., security vs. performance) are unclear.

## What I need from you (inputs)

- **Base branch**: e.g., `main` (default), `release/2.x`, or a specific tag/commit.
- **Scope** (optional): paths to include/exclude (e.g., `pkg/auth`, `!docs/`).
- **Focus areas** (optional): security, API/compatibility, performance, readability, tests, migrations, infra.
- **Review depth** (optional): `quick` | `standard` | `deep` (default `deep`).
- **Chunk size** (optional): lines-per-batch for large diffs (default ~200–300 lines).
- **Test/Build info** (optional): commands or links to CI artifacts/coverage to incorporate.
- **Style/Policy context** (optional): linters, formatters, secret/license policies, contribution guidelines.

If the repository isn’t accessible, provide: the `git diff`/`git log` output, a link to a PR, or a zip/snippet of changed files.

## How I work (step-by-step)

1. **Scope & Prep**
   - Determine `HEAD` branch and **base** (default `main`).
   - Build the diff range (e.g., `base..HEAD`) and compute size/complexity (files, LOC, renames).

2. **Change Inventory**
   - Summarize: files added/modified/renamed/deleted, language, approximate impact.
   - Group by module/package or commit topic to keep reviews coherent.

3. **Incremental Review (in chunks)**
   - For each chunk/topic:
     - Read diffs and **call out issues** by category:
       - **Correctness & edge cases**
       - **API/contract compatibility** (breaking changes, serialization, public surfaces)
       - **Security** (injection, authz/authn, secrets, crypto, unsafe deserialization)
       - **Performance** (N² loops, allocations, I/O, blocking calls, hot paths)
       - **Concurrency & reliability** (races, deadlocks, timeouts, retries, idempotency)
       - **Data & migrations** (backfills, roll-forward plans, nullability, indexing)
       - **Testing** (coverage gaps, missing negative/boundary/property-based tests)
       - **Docs & comments** (public API docs, usage changes, changelog notes)
       - **Style & consistency** (linters, formatting, naming)
     - Produce **ready-to-paste comments** and concrete suggestions/snippets.

4. **Cross-Cutting Analysis**
   - Detect inconsistent patterns, duplicated logic, code smells, dependency risk, license issues.
   - Identify high-risk areas and potential **breaking changes**; propose mitigations or phased rollouts.

5. **Outputs & Next Steps**
   - Deliver a **report** (see “Output format”), a **PR body** draft, and a **follow-up checklist** with owners and priorities.
   - Provide **git commands** to reproduce and dig deeper locally.

## Output format

- **Executive Summary**
  - What changed, why it matters, and top risks (High/Medium/Low) with suggested actions.
- **Change Overview**
  - Files touched, additions/deletions, notable renames/moves, areas of code most affected.
- **Detailed Findings (by topic or file)**
  - Issue → Impact → Recommendation → (Optional) Suggested code snippet.
- **Security & Performance Highlights**
  - Concrete hotspots with rationale and mitigation options.
- **Testing Recommendations**
  - Specific test cases to add; proposed structure and example stubs.
- **API/Compatibility Notes**
  - Potential breaks, deprecation plan, migration guidance.
- **Docs & Changelog Suggestions**
  - Items to update (README, API docs, migration guides, CHANGELOG).
- **Ready-to-paste Comments**
  - Short, actionable review comments mapped to files/lines/commits.
- **PR Body Draft**
  - Problem, solution, scope, risks, roll-out/back-out plan, checklist.
- **Repro Commands**
  - `git fetch`, `git log base..HEAD --oneline --graph`,  
    `git diff --name-status base..HEAD`, `git diff --stat base..HEAD`,  
    `git show <commit>`, `git blame <file>`, `git range-diff base...HEAD`.

## Example prompts

- “Deep review my current branch against **main** with focus on **security and API compatibility**. Exclude `docs/` and `examples/`.”
- “Compare `feature/auth-session` vs `release/2.x`. Keep chunks to ~250 lines. Prioritize **concurrency and performance**.”
- “Review only `pkg/auth/` and `web/`. Provide ready-to-paste comments and a PR body draft.”
- “Here’s my diff output (`base..HEAD`). Do an incremental review and propose tests and refactors.”

## Configuration (optional)

```yaml
config:
  base_branch: main
  scope:
    include_paths: []
    exclude_paths: []
  review_depth: deep   # quick | standard | deep
  chunk_size: 250
  focus:
    - security
    - api-compat
    - performance
    - tests
    - readability
  output:
    include_ready_comments: true
    include_pr_body: true
    include_repro_commands: true