---
name: pr-description
description: Writes pull request titles and bodies. Use this skill whenever the user asks to write, draft, generate, or create a PR description, pull request body, or PR title — even if they phrase it casually like "write up the PR" or "describe these changes". Also invoked from `changes-workflow` step 6 when opening a PR.
model: sonnet
---

### Step 1: Research the changes

Before writing anything, gather context by running:
```bash
git log main..HEAD --oneline
git diff main --stat
```

Read the output to understand what was actually changed — which files, how many lines, and what the commits say. This context is what makes the PR description accurate and useful.

### Step 2: PR Title

Follow the format: `<type>: <short description>` — colon, no brackets. This differs intentionally from commit subjects, which use `[<type>] <description>` (brackets). See `commit-message` skill for commit subject format.

Examples:
- `feat: add date filter to dashboard`
- `fix: prevent duplicate session creation`
- `chore: upgrade typescript to 5.x`

### Step 3: Select template

Infer branch type from the current branch name prefix and load the matching template:

| Prefix | Template |
|---|---|
| `feat/` | [feature.md](assets/templates/feature.md) |
| `fix/` | [fix.md](assets/templates/fix.md) |
| `exp/` | [experiment.md](assets/templates/experiment.md) |
| `opt/` | [optimization.md](assets/templates/optimization.md) |
| `refactor/` | [refactor.md](assets/templates/refactor.md) |
| `chore/` | [chore.md](assets/templates/chore.md) |
| `docs/` | [docs.md](assets/templates/docs.md) |

If the branch prefix doesn't match any of the above, default to [feature.md](assets/templates/feature.md).

### Step 4: Fill in the template

Write 1–3 sentences per section. Focus on the *what* and *why* from the user's perspective — avoid listing variable names, file names, or low-level implementation details unless they're genuinely essential to understanding the change.

Good examples:
- "Added a date filter to the dashboard so users can scope data to a specific time range."
- "Fixed a memory leak in the session cleanup routine that caused gradual heap growth under load."
- "Extracted auth logic into a dedicated service to reduce duplication across three route handlers."

### Step 5: Complete the checklist

Go through each checklist item and tick only those you can verify from the diff:
- Check the box (`[x]`) if the condition is clearly met based on what you can see
- Leave the box unchecked (`[ ]`) if it requires human judgment or you can't confirm it from the diff

Don't tick boxes speculatively. The checklist is a review aid, not a formality.

### Output

Return both fields to the caller so they can be passed to `gh pr create --title "<title>" --body "<body>"`:

```
- **Title**: <type>: <short description>
- **Body**:
<rendered template content>
```
