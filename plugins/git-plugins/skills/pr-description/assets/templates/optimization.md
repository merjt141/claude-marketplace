## optimization: [Short description]

### What bottleneck does this address?
<!-- Explain the performance issue -->

### Benchmark results

| Metric | Before | After | Improvement |
|---|---|---|---|
| | | | |

### Approach
<!-- Describe the optimization -->

### Review Checklist

#### Universal
- [ ] PR has the `optimization` label
- [ ] PR title follows `optimization: <short description>` format
- [ ] Branch follows `opt/<short-description>` naming
- [ ] PR description explains what and why
- [ ] Changes follow KISS principle
- [ ] Imports are properly grouped and no unused imports exist
- [ ] Naming conventions are followed
- [ ] No commented-out or dead code
- [ ] No secrets or credentials in code
- [ ] One concern per PR (no unrelated changes bundled)
- [ ] Diff contains only changes necessary for the PR's goal (no drive-by refactors or cosmetic changes)

#### Optimization-Specific
- [ ] Benchmark or metric results included (before vs. after)
- [ ] No observable behavior change
- [ ] Bottleneck motivation explained
