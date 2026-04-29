---
name: commit-message
description: Writes a single-line git commit message. Use this skill whenever the user asks to commit, write a commit message, stage changes, or draft a commit subject — even if they just say "commit this" or "what should my commit say?".
model: sonnet
---

### Commit Messages

Write one line, imperative mood, under 72 characters. Describe *what* changed, not *how* or *why*. The reader can see the diff for how — the commit message should communicate the intent at a glance.

**Format:** `[<type>] <description>`

Brackets around the type — this intentionally differs from PR titles, which use `type: description` (colon, no brackets). See the `pr-description` skill.

**Valid types:** `feat`, `fix`, `refactor`, `chore`, `docs`, `exp`, `opt`

**Good:**
- `[feat] add date filter to dashboard`
- `[fix] duplicate session on refresh`
- `[refactor] extract auth logic into middleware`

**Bad:**
- `[feat] Added date filter to dashboard` ← past tense, not imperative
- `[fix] Fixed the bug where sessions were duplicated on refresh` ← too long, describes how
- `Updated the dashboard component to add a new date filter feature` ← no type, no format
