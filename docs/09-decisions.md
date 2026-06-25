# Architecture Decision Records

Significant technical decisions for **Billing Baba**. Copy the template below for each new decision.

## ADR Index

| ID | Title | Date | Status |
|----|-------|------|--------|
| ADR-001 | Project Initialization | June 2026 | Accepted |

---

## ADR-001: Project Initialization

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

#### Context

Billing Baba requires a cross-platform POS and billing application with offline capability, cloud sync, and support for desktop and mobile platforms.

#### Decision

- **Flutter** for the client — single codebase for Windows, macOS, Android, and iOS
- **Fastify** for the REST API — lightweight, performant Node.js framework
- **Offline-first architecture** — local SQLite as the primary data store
- **SQLite + PostgreSQL** — SQLite on device via Drift; PostgreSQL in the cloud via Drizzle for sync and backup

#### Reasoning

- Flutter provides native desktop and mobile from one codebase, reducing maintenance for a small team
- Fastify aligns with the Node.js ecosystem and Drizzle ORM for PostgreSQL
- Offline-first ensures uninterrupted POS operation; cloud sync handles backup and multi-device use

#### Consequences

- Team must manage sync logic between local and cloud databases
- Flutter desktop tooling requires ongoing attention as the platform matures
- API scope is focused on auth, sync, and backup — not real-time POS operations

---

## ADR Template

### ADR-<ID>: <Title>

| Field | Value |
|-------|-------|
| **Date** | `<DATE>` |
| **Status** | Proposed / Accepted / Deprecated / Superseded |
| **Author** | `<TEAM_MEMBER>` |

#### Context

<!-- What problem or situation requires a decision? -->

#### Decision

<!-- What was decided? -->

#### Reasoning

<!-- Why this option over alternatives? -->

#### Consequences

<!-- What becomes easier or harder? -->
