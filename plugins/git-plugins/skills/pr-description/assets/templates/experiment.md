## experiment: [Short description]

### Hypothesis / Goal
<!-- What are you trying to validate? What is the expected outcome? -->

### Approach
<!-- Describe the experimental approach -->

### Scope of changes
<!-- List what files/modules are affected and confirm isolation -->

### Rollback plan
<!-- The `exp/` branch enables automated rollback. Confirm changes are self-contained. -->

> **Reminder:** You have **14 calendar days** from merge to report the outcome.
> If passed, open a `feat/` PR to formalize the experiment.
> If no report is received, an automated revert PR will be generated.

### Review Checklist

#### Universal
- [ ] PR has the `experiment` label
- [ ] PR title follows `experiment: <short description>` format
- [ ] Branch follows `exp/<short-description>` naming
- [ ] PR description explains what and why
- [ ] Changes follow KISS principle
- [ ] Imports are properly grouped and no unused imports exist
- [ ] Naming conventions are followed
- [ ] No commented-out or dead code
- [ ] No secrets or credentials in code
- [ ] One concern per PR (no unrelated changes bundled)
- [ ] Diff contains only changes necessary for the PR's goal (no drive-by refactors or cosmetic changes)

#### Experiment-Specific
- [ ] Hypothesis or goal clearly stated
- [ ] Changes are self-contained and isolated
- [ ] Existing functionality is not broken
- [ ] No security vulnerabilities introduced
- [ ] Easy to roll back
- [ ] Branch uses the `exp/` prefix
- [ ] Author acknowledges the 14-day reporting deadline (automated rollback on expiry)
