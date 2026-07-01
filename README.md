# Billing Baba

## Overview

**Billing Baba** is offline-first POS, billing, and business management software for small and medium businesses. It runs on desktop and mobile, works without a network connection, and syncs data to the cloud when online.

## Features

- Point of sale and invoicing
- Product and inventory management
- Customer management
- Business reports
- Offline operation with cloud sync and backup
- Multi-device synchronization

## Tech Stack


| Layer            | Technology                             |
| ---------------- | -------------------------------------- |
| Client           | Flutter (Windows, macOS, Android, iOS) |
| Backend          | Fastify REST API                       |
| Local Database   | SQLite (Drift)                         |
| Cloud Database   | PostgreSQL (Drizzle)                   |
| State Management | Riverpod                               |
| Navigation       | GoRouter                               |




## Repository Structure

```
billing-baba/
├── apps/
│   ├── client/        # Flutter app (desktop + mobile)
│   └── api/           # Fastify REST API
├── docs/              # Project documentation
├── scripts/           # Automation scripts
├── .github/           # PR template, issue templates, CI workflows
└── .cursor/           # Cursor configuration
```



## Getting Started

> Setup instructions will be added once the development environment is finalized. See [docs/02-development.md](docs/02-development.md).



## Documentation


| Document                                                  | Description                     |
| --------------------------------------------------------- | ------------------------------- |
| [00-project.md](docs/00-project.md)                       | Overview, scope, team, timeline |
| [01-architecture.md](docs/01-architecture.md)             | System structure and key flows  |
| [02-development.md](docs/02-development.md)               | Local setup and commands        |
| [03-design-system.md](docs/03-design-system.md)           | UI guidelines                   |
| [04-database.md](docs/04-database.md)                     | Schema and migrations           |
| [05-api.md](docs/05-api.md)                               | API endpoints                   |
| [06-coding-standards.md](docs/06-coding-standards.md)     | Code style and conventions      |
| [07-git-workflow.md](docs/07-git-workflow.md)             | Git branching and pull requests |
| [08-project-management.md](docs/08-project-management.md) | Sprints and ClickUp workflow    |
| [09-decisions.md](docs/09-decisions.md)                   | Architecture decision records   |




## Development Workflow

1. Pick up a task from ClickUp and move it to **In Progress**.
2. Create a feature branch from `develop` — see [docs/07-git-workflow.md](docs/07-git-workflow.md).
3. Implement, test, and open a Pull Request to `develop`.
4. Address review feedback and merge after approval.
5. Move the ClickUp task to **Done**.

Project planning and tasks are tracked in ClickUp — see [docs/08-project-management.md](docs/08-project-management.md).