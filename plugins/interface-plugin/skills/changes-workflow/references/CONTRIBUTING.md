# Contributing Guide

Read this file before implementing any change.

---

## Code Reuse First

Before writing any new code, search the codebase for existing functionality.

1. **Search before building.** Check `services/`, `lib/`, `utils/`, `components/ui/`, and `context/` for existing implementations.
2. **Extend, don't duplicate.** If an existing module partially covers the need, extend it rather than creating a new one.
3. **Follow existing patterns.** Find similar code in the codebase and follow the same approach.

## Minimal Diff

Every changed line must be directly traceable to the task goal.

- Do NOT refactor, rename, or restyle surrounding code. Open a separate `refactor/` PR.
- Do NOT reorganize imports, adjust whitespace, or reorder methods in files you are touching.
- Do NOT make "while I'm here" improvements. Each improvement deserves its own PR.

> **Rule of thumb:** If you remove a change from the diff and the PR still achieves its goal, that change should not be in the PR.

## Conventions

### Naming

- **Files:** `kebab-case` (e.g., `user-profile.ts`)
- **Variables & functions:** `camelCase` (e.g., `getUserProfile`)
- **Classes & types:** `PascalCase` (e.g., `UserProfile`)
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Booleans:** Prefix with `is`, `has`, `should`, `can` (e.g., `isActive`)
- Names must be descriptive. No single-letter variables outside short lambdas or loop indices.

### Imports

Group in this order, separated by a blank line:
1. External/third-party packages
2. Internal/project modules (absolute paths with `@/`)
3. Relative imports within the same feature

No wildcard (`*`) imports. Remove unused imports. Prefer named exports over default exports.

## Frontend-Specific Rules

### API Pattern (mandatory)

All data flows through this pattern:

```
Client component → services/ function → Next.js API route (app/api/) → Backend API
```

- Client code NEVER calls backend APIs directly
- API routes resolve tenant credentials via `lib/tenantResolver.ts`
- Tenant ID comes from client headers, resolved server-side

### Types

- All shared interfaces go in `interface/` (not colocated with components)
- One file per domain: `conversation.ts`, `messages.ts`, `dashboard.ts`, etc.
- Use existing types before creating new ones — check `interface/` first

### Components

- shadcn/ui base components in `components/ui/` — use them, don't reinvent
- Page-specific components colocated in their route directory under `app/`
- Tailwind CSS v4 for styling — no inline styles, no CSS-in-JS

### Context / State

- Don't create new context providers without strong justification
- Existing providers: `TenantContext`, `SocketContext`, `SocketEventsContext`, `MessagesContext`, `ToastContext`, `SidebarContext`
- Prefer local state (`useState`) over context for component-specific state

## Following Up on a PR

To resume work on an existing PR (address review comments, fix CI failures):

```
claude --from-pr <PR_NUMBER>
```

This picks up the session linked to that PR with full context.

## Protected Files

Do NOT modify without explicit tech team approval:
- `middleware.ts` — auth and route protection
- `next.config.ts` — security headers and redirects
- `.github/` — CI/CD workflows
- `lib/tenantResolver.ts` — tenant credential mapping
