# Git Workflow

## Purpose

This document defines the Git and GitHub workflow for **Billing Baba**.

## Branch Strategy

We follow a lightweight Git Flow.

```
main
 │
 └────────────── develop
                  │
        ┌─────────┴─────────┐
        │         │         │
   feature/auth feature/dashboard feature/inventory
```

| Branch | Purpose |
|--------|---------|
| `main` | Stable production-ready code |
| `develop` | Active development branch |
| `feature/*` | New features |
| `fix/*` | Bug fixes |
| `hotfix/*` | Urgent fixes for production |
| `chore/*` | Maintenance and tooling |

### Rules

- Never commit directly to `main`.
- Never commit directly to `develop`.
- Every change starts from a feature branch.
- Merge feature branches into `develop`.
- Merge `develop` into `main` only for releases.

## Branch Naming

```
feature/login
feature/dashboard
feature/inventory
fix/sidebar-overflow
hotfix/auth-crash
chore/update-dependencies
```

Keep names:

- lowercase
- short
- descriptive
- hyphen-separated

## Workflow

1. Switch to `develop` and pull the latest changes
2. Create a new feature branch from `develop`
3. Implement your changes and commit regularly
4. Push your branch
5. Open a Pull Request to `develop`
6. Address review comments
7. Merge after approval
8. Delete your local and remote feature branch

## Feature Ownership

Each feature or module should have one primary owner.

Avoid multiple developers working on the same files unless coordinated. This helps reduce merge conflicts and keeps responsibilities clear.

## Keeping Your Branch Updated

Before opening a Pull Request:

```bash
git fetch origin
git checkout feature/your-feature
git rebase origin/develop
```

This guarantees you're rebasing against the latest remote `develop`, even if your local `develop` is outdated.

Resolve conflicts if any.

Push using:

```bash
git push --force-with-lease
```

Use `--force-with-lease`, never `--force`.

## Resolving Merge Conflicts

If Git reports a conflict:

1. Open the conflicted files.
2. Look for:

```
<<<<<<< HEAD
Your changes
=======
Incoming changes
>>>>>>> develop
```

3. Keep the correct code.
4. Remove conflict markers.
5. Save the file.

Then run:

```bash
git add .
git rebase --continue
```

Repeat until the rebase completes. If new conflicts appear, resolve them using the same process.

If you want to cancel:

```bash
git rebase --abort
```

If you're unsure, ask the team before resolving.

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add authentication screen
fix: resolve sidebar scrolling issue
refactor: simplify invoice calculations
docs: update architecture document
chore: update dependencies
```

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change, no feature/fix |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependencies |

## Pull Requests

Before creating a PR:

- Sync with `develop`
- Resolve conflicts
- Test your changes
- Ensure the project builds successfully

Use the [PR template](../.github/PULL_REQUEST_TEMPLATE.md).

The PR description should clearly explain:

- What changed
- Why it changed
- Anything the reviewer should pay attention to

## Code Reviews

Reviews should focus on:

- Correctness
- Readability
- Maintainability
- Performance
- Simplicity

Be constructive and respectful.

## Merge Rules

- Merge into `develop`
- At least one approval required
- Project must build successfully
- Resolve all review comments before merging
- Use **Squash and Merge**
- Delete the feature branch after merging

## Best Practices

- Keep one feature per branch.
- Keep Pull Requests small.
- Commit frequently.
- Rebase before opening a PR.
- Never rewrite shared branch history.
- Never push directly to `main` or `develop`.
- Ask for help early if blocked.

## Quick Git Commands

```bash
# Update develop
git checkout develop
git pull

# Create feature branch
git checkout -b feature/your-feature

# Commit
git add .
git commit -m "feat: add login screen"

# Push
git push -u origin feature/your-feature

# Rebase
git fetch origin
git rebase origin/develop

# Continue after conflict
git add .
git rebase --continue

# Abort rebase
git rebase --abort
```

## Checklist

- [ ] Branch protection rules configured on `main` and `develop`
- [ ] CI checks required before merge
