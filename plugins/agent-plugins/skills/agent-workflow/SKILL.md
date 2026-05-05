---
name: agent-workflow
description: Guides the user through the agent workflow. Use when the user asks to perform changes following the defined agent workflow.
model: sonnet
---

Follow the steps in order. Each has a stop condition — if it fails, ask the user, do not improvise.

## Communication

- **Language**: Spanish by default. Mirror English only if the user writes in English. Procedural prompts (plan, approval, errors) stay in Spanish.
- **English Items**: commit subjects, PR titles, PR bodies, branch names. The `commit-message` and `pr-description` skills output English — do not translate.
- **Audience ops**: most users are non-technical. Translate git/CLI errors into plain language; if you must show the raw error, follow with a one-line summary.
- **Destructive operations**: confirm before any irreversible action (`--force`, `reset --hard`, branch deletion, overwriting files outside the planned diff). Permission does not carry over.

## 0. Pre-flight

Stop and report the exact error if any check fails and guide the user into how to solve it.

1. **Auth & identity**: `gh auth status` and `git config user.name && git config user.email`.
2. **Sync**: `git fetch origin --prune` then `git checkout main && git pull --ff-only`.
3. **Detect base branch** — try `dev`, `development`, `main` in order, stop at first found:
   ```bash
   for b in dev development main; do
     git ls-remote --exit-code --heads origin "$b" >/dev/null 2>&1 && echo "$b" && break
   done
   ```
   Remember the literal value — Bash calls run in fresh shells.
4. **Detect repo and type**:
   - Slug: `gh repo view --json nameWithOwner -q .nameWithOwner`.
   - From `package.json` deps: `next` → frontend, `express` → backend, neither → library.
5. **Detect npm scripts**: read `package.json` `.scripts`. Only run `lint`, `typecheck`, `dev` later if they exist.
6. **Load engineering standards**:
   ```bash
   gh api repos/PEOPL-Health-Tech/engineering-standards/contents/prompt-guidelines/GENERAL.md \
     -H "Accept: application/vnd.github.raw"
   ```
   Treat as binding context for the rest of the workflow.
7. **Explore and understand the repo**: browse the codebase to learn its conventions before writing code. Reuse existing services rather than reimplementing.

## 1. Capture intent

Land on these three fields. If the user gave an issue link, pre-fill from `gh issue view <number> --json title,body,url` and ask only for gaps. For trivial requests ("rename Y prop", "fix typo"), skip the structure.

- **Descripción**
- **Cómo reproducir** *(bugs only)*
- **Comportamiento esperado**

### Cross-repo investigation

If the task signals another repo (a frontend bug naming a backend endpoint, a `nexus` change, the user names another service), fetch that repo's docs proactively — do not ask permission, tell the user in one line which docs you loaded. Same rule applies later if the signal first appears during implementation or review. If no docs/ directory exists, fetch the README.md file.

| Repo | Role |
|---|---|
| `peopl-interface` | Frontend (Next.js) |
| `peopl-auna` | Backend (Express) |
| `peopl-assist` | Backend (Express) |
| `orbis` | Service server |
| `nexus` | Shared library consumed by backends |

```bash
gh api repos/PEOPL-Health-Tech/<repo>/contents/README.md -H "Accept: application/vnd.github.raw"
gh api repos/PEOPL-Health-Tech/<repo>/contents/docs?ref=main --jq '.[].name'
gh api repos/PEOPL-Health-Tech/<repo>/contents/docs/<file> -H "Accept: application/vnd.github.raw"
```

## 2. Classify scope

Invoke `scope-delimiter`. **Do not wait for user input after the skill returns.** If `Fits in one PR = yes`: immediately continue to step 3 in the same response turn. If `Fits in one PR = no`: show the split proposal, ask which sub-PR to tackle first, and wait for the user's answer before continuing.

## 3. Plan and get approval
Before planining, load the specific gudeline based on task type:
   |type|guideline|
   |---|---|
   |feat|feature|
   |fix|fix|
**Use guideline cell value when fetching the guideline file.**
```bash
   gh api repos/PEOPL-Health-Tech/engineering-standards/contents/prompt-guidelines/types/<guideline>.md \
     -H "Accept: application/vnd.github.raw"
   ```
Use that guideline along the engineering standards to build the pre-filled plan and show it to the user. Wait for clear approval ("sí", "dale", "listo", "aprobado"). Anything ambiguous is not approval.

- **Type**: <from scope-delimiter>
- **Branch name**: `<type>/<short-kebab-case>`
- **Base branch**: <from step 0.3>
- **Reviewer**: merjt141
- **Descripción / Cómo reproducir / Comportamiento esperado**: <from step 1>
- **Files to touch**
- **Plan**
- **Test plan**: <URL/interaction for step 6> or `N/A`
- **Aprobación**: Responde "sí" / "dale" / "listo" para continuar.

## 4. Prepare branch and implement

1. `git status` must be clean. If not, ask how to proceed.
2. Branch from base: `git checkout -b <type>/<short-name> origin/<base>`. If the branch exists, ask before overwriting.
3. Implement the plan.
4. Run `npm run lint` and `npm run typecheck` if they exist. Fix errors before continuing.

## 5. Diff review

Launch `diff-reviewer`, passing it the approved plan from step 3 (Type, Files to touch, Plan steps) and the base branch detected in step 0.3 — the reviewer needs both as inputs. Report its findings.

If it flags issues: fix, re-run lint/typecheck, re-launch. Cap at 3 rounds — surface remaining items to the user beyond that.

## 6. Visual review (frontend only)

Skip if: backend/library repo, branch is `docs/`/`chore/`/`refactor/`, or diff doesn't touch `app/` or `components/`.

Otherwise: `npm run dev` (port 3000), tell the user the URL to open and what to verify, stop the server once confirmed.

## 7. Commit and open PR

1. Invoke `commit-message` for the subject. **Do not wait for user input after the skill returns — immediately proceed to step 2.**
2. Stage by name (`git add path/one path/two`) — include new files created during step 4. Never `git add -A` or `git add .`.
3. Commit with the drafted subject.
4. `git push -u origin <branch>`. On rejection, surface the error — do not retry with `--force`.
5. Invoke `pr-description` for title and body. **Do not wait for user input after the skill returns — immediately proceed to step 6.**
6. Open as draft:
   ```bash
   gh pr create --base <base> --draft --title "<title>" --body "<body>" --reviewer merjt141
   ```

## 8. Wait for CI, then mark ready

```bash
gh pr checks <pr-number> --watch
```

- **Pass** → `gh pr ready <pr-number>` and report the URL.
- **Fail** → fetch `gh run view <run-id> --log-failed`, report to user, ask whether to fix or hand off. If fixing: re-enter at step 4, then 5, then 7.4. PR stays draft until CI passes.
