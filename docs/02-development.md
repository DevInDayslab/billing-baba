# Development

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

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | Latest stable |
| Node.js | LTS |
| Git | Latest |
| Cursor | Latest |
| PostgreSQL | <!-- TBD --> |

## Setup

> Detailed setup commands for Flutter and Fastify will be added once the development environment is finalized.

1. Clone the repository:
   ```bash
   git clone <!-- repository URL -->
   cd billing-baba
   ```

2. Install dependencies — instructions coming soon for each app.

3. Copy `.env.example` to `.env` and fill in values.

4. Start development servers — instructions coming soon.

For Git workflow, see [07-git-workflow.md](07-git-workflow.md).

## Useful Commands

| Command | Description |
|---------|-------------|
| | Start dev server |
| | Run tests |
| | Run linter |
| | Build for production |

> Commands will be documented per app once setup is complete.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| | | <!-- TBD --> |

Never commit `.env` files.

## Development Workflow

1. Pick up a task from ClickUp.
2. Create a feature branch from `develop` — see [07-git-workflow.md](07-git-workflow.md).
3. Implement and test locally.
4. Open a Pull Request to `develop`.
5. Address review feedback and merge after approval.

## Troubleshooting

Add issues here as they come up.

| Problem | Solution |
|---------|----------|
| Dependencies fail to install | |
| Server won't start | |
| Tests fail locally | |
