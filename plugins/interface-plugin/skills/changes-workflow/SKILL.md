---
name: changes-workflow
description: Guides the user through the changes workflow. Use when the user asks to perform changes following the defined workflow.
model: sonnet
---

## Workflow

Always read [CONTRIBUTING.md](./references/CONTRIBUTING.md) for detailed requirements before planning or exploring the code to implement a feature, fix, or code change, and follow the workflow below:

1. Ensure you are in `main` branch and changes are up to date with `git fetch --all` and `git checkout main` and `git pull`. Then Invoke the `scope-delimiter` skill. Wait for its output before proceeding.
   - If `Fits in one PR` = `no`: stop and ask the user which sub-PR from the split proposal to tackle first. Do not continue this workflow until the user picks one.
2. Plan the simplest approach (KISS) and get user approval with the following template (pre-filled with `scope-delimiter` output):
   - **Type**: <!-- type from scope-delimiter -->
   - **Branch name**: <!-- <type>/<short-kebab-case> from scope-delimiter -->
   - **Root cause/Description**: <!-- bug or changes explanation -->
   - **Files to touch**: <!-- bullet list of files to edit/create -->
   - **Plan**: <!-- sequential steps -->
   - **Test plan**: <!-- what URL / interaction to verify in browser at step 5, or "N/A — non-UI change" -->
   - **Approval Query:** <!-- ask permission and show next steps -->
3. Prepare branch and implement:
   1. Verify working tree is clean (`git status`). If not, ask the user how to proceed (stash, commit, discard) before continuing.
   2. Create the branch from `origin/main`: `git fetch origin && git checkout -b <type>/<short-name> origin/main`.
   3. Implement the plan, then run `npm run lint` and `npm run typecheck`. Fix any errors before continuing.
4. Launch the `diff-reviewer` subagent and report its findings to the user.
   - If issues are reported and require code changes: apply the fixes, re-run `npm run lint` and `npm run typecheck`, then re-launch `diff-reviewer`. Repeat until no blocking issues remain.
5. Visual review (skip for `docs/`, `chore/`, `refactor/` types, or any change that does not affect `app/` or `components/`):
   1. Start `npm run dev` on port 3000 (if port is busy, kill the process using it first).
   2. Guide the user to the specific URL to verify (from the Test plan in step 2).
   3. After the user confirms the changes are working, stop the dev server and proceed.
6. Commit and open PR:
   1. Invoke the `commit-message` skill to draft the commit subject.
   2. Stage only the files listed in the plan (`git add <file> <file> ...` — do NOT use `git add -A` or `.`) and commit with the drafted subject.
   3. Push the branch: `git push -u origin <branch>`.
   4. Invoke the `pr-description` skill to draft the PR title and body.
   5. Create the PR targeting the `development` branch: `gh pr create --base development --draft --title "<title>" --body "<description>" --reviewer merjt141`.
7. Wait for CI with `gh pr checks <pr-number> --watch`. When all checks pass, mark ready: `gh pr ready <pr-number>`. Report the PR URL.

## Rules

1. Do not use Edit/Write directly without user approval — use the Workflow instead.

## Branch Naming

| PR Type | Prefix | Example |
|---------|--------|---------|
| Feature | `feat/` | `feat/user-onboarding` |
| Fix | `fix/` | `fix/duplicate-session` |
| Experiment | `exp/` | `exp/vector-search-approach` |
| Optimization | `opt/` | `opt/query-batching` |
| Refactor | `refactor/` | `refactor/auth-module` |
| Chore | `chore/` | `chore/upgrade-typescript` |
| Docs | `docs/` | `docs/api-reference` |

CI automatically assigns the correct PR template based on branch prefix.
