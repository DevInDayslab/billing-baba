# Project Management

Tasks are tracked in **ClickUp**. GitHub Issues are for bugs and engineering tasks only.

## Phases

| Phase | Deliverable |
|-------|-------------|
| Project Setup | Repository, tooling, and documentation |
| Discovery | Scope, designs, and architecture |
| Development | Features per sprint |
| QA & Launch | Signed-off release |

## Sprint Workflow

| Activity | When |
|----------|------|
| Sprint planning | Day 1 |
| Daily standup | Daily |
| Sprint review | Last day |

**Sprint length:** 2 weeks

## ClickUp Workflow

| Status | Meaning |
|--------|---------|
| To Do | Ready for development |
| In Progress | Being worked on |
| In Review | PR open |
| QA | In testing |
| Done | Merged and verified |
| Blocked | Waiting on dependency |

## Pull Requests & Code Reviews

- Every change goes through a Pull Request to `develop`
- At least one approval required before merge
- Use **Squash and Merge** — see [07-git-workflow.md](07-git-workflow.md)
- Move ClickUp task to **In Review** when PR is open

## Definition of Ready

- [ ] Requirements and acceptance criteria are clear
- [ ] Designs available (if UI work)
- [ ] No blockers

## Definition of Done

- [ ] Code follows [06-coding-standards.md](06-coding-standards.md)
- [ ] Pull request reviewed and merged to `develop`
- [ ] Acceptance criteria verified
- [ ] Happy path and edge cases tested
- [ ] No console errors (if applicable)
- [ ] Desktop and mobile layouts verified (if UI work)
- [ ] ClickUp task moved to **Done**
