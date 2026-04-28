## refactor: [Short description]

### Motivation
<!-- Why is this refactor needed? (readability, maintainability, reducing duplication, etc.) -->

### What changed structurally?
<!-- Describe the restructuring -->

### Review Checklist

#### Universal
- [ ] PR has the `refactor` label
- [ ] PR title follows `refactor: <short description>` format
- [ ] Branch follows `refactor/<short-description>` naming
- [ ] PR description explains what and why
- [ ] Changes follow KISS principle
- [ ] Imports are properly grouped and no unused imports exist
- [ ] Naming conventions are followed
- [ ] No commented-out or dead code
- [ ] No secrets or credentials in code
- [ ] One concern per PR (no unrelated changes bundled)
- [ ] Diff contains only changes necessary for the PR's goal (no drive-by refactors or cosmetic changes)

#### Refactor-Specific
- [ ] No observable behavior change
- [ ] Existing tests pass without modification
- [ ] Motivation explained (readability, maintainability, etc.)
