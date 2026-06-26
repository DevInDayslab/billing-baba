# Architecture Decision Records

## Purpose

Record significant architectural and technical decisions for Billing Baba. ADRs provide context for why the system is built the way it is.

## Scope

Phase 1 decisions. Superseded decisions will be marked when stack changes occur.

**Related docs:** [01-architecture.md](01-architecture.md) · [04-database.md](04-database.md) · [05-api.md](05-api.md)

## Table of Contents

- [ADR Index](#adr-index)
- [ADR-001: Why PostgreSQL](#adr-001-why-postgresql)
- [ADR-002: Why UUID](#adr-002-why-uuid)
- [ADR-003: Why Modular Monolith](#adr-003-why-modular-monolith)
- [ADR-004: Why REST](#adr-004-why-rest)
- [ADR-005: Why Drizzle](#adr-005-why-drizzle)
- [ADR-006: Why Flutter](#adr-006-why-flutter)
- [ADR-007: Offline First](#adr-007-offline-first)
- [ADR-008: Soft Delete](#adr-008-soft-delete)
- [ADR-009: Single Source of Truth](#adr-009-single-source-of-truth)
- [ADR-010: Business Domain Separation](#adr-010-business-domain-separation)
- [ADR-011: Why Fastify](#adr-011-why-fastify)
- [ADR-012: Why Drift](#adr-012-why-drift)
- [ADR-013: Why Riverpod](#adr-013-why-riverpod)
- [ADR-014: Unified Sales Documents](#adr-014-unified-sales-documents)
- [ADR-015: Unified Purchase Documents](#adr-015-unified-purchase-documents)
- [ADR-016: Event-based Inventory Ledger](#adr-016-event-based-inventory-ledger)
- [ADR-017: Double Entry Accounting](#adr-017-double-entry-accounting)

---

## ADR Index

| ID | Title | Date | Status |
|----|-------|------|--------|
| ADR-001 | Why PostgreSQL | June 2026 | Accepted |
| ADR-002 | Why UUID | June 2026 | Accepted |
| ADR-003 | Why Modular Monolith | June 2026 | Accepted |
| ADR-004 | Why REST | June 2026 | Accepted |
| ADR-005 | Why Drizzle | June 2026 | Accepted |
| ADR-006 | Why Flutter | June 2026 | Accepted |
| ADR-007 | Offline First | June 2026 | Accepted |
| ADR-008 | Soft Delete | June 2026 | Accepted |
| ADR-009 | Single Source of Truth | June 2026 | Accepted |
| ADR-010 | Business Domain Separation | June 2026 | Accepted |
| ADR-011 | Why Fastify | June 2026 | Accepted |
| ADR-012 | Why Drift | June 2026 | Accepted |
| ADR-013 | Why Riverpod | June 2026 | Accepted |
| ADR-014 | Unified Sales Documents | June 2026 | Accepted |
| ADR-015 | Unified Purchase Documents | June 2026 | Accepted |
| ADR-016 | Event-based Inventory Ledger | June 2026 | Accepted |
| ADR-017 | Double Entry Accounting | June 2026 | Accepted |

---

## ADR-001: Why PostgreSQL

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Billing Baba requires a cloud database for multi-device sync, backup, and relational integrity across parties, inventory, sales documents, ledger entries, and payments. The PRD defines complex B2B workflows with foreign keys, transactional consistency (finalize invoice = stock + ledger), and Indian GST reporting.

### Decision

Use **PostgreSQL** as the cloud database, hosted on **NeonDB** (serverless PostgreSQL with branching for staging).

### Consequences

**Positive:**

- ACID transactions for finalize flows (stock movement + ledger + document status in one transaction)
- Mature indexing, constraints, and JSON columns for `online_orders.order_payload`
- Strong ecosystem with Drizzle, NeonDB branching, and backup tooling
- NeonDB serverless scaling and database branching for preview environments
- Row-level tenant isolation via `business_id` without per-tenant databases in Phase 1

**Negative:**

- Requires managed hosting and migration discipline
- SQLite (client) and PostgreSQL schemas must stay aligned manually via Drift + Drizzle

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| MongoDB | Poor fit for ledger and document-line relational model; reporting queries are relational |
| MySQL | Comparable to PostgreSQL; PostgreSQL has stronger JSON and constraint tooling |
| Firebase/Firestore | Offline sync model conflicts with custom sync requirements; query limitations for reports |
| Per-device cloud only | No multi-device sync or centralized backup |

**References:** [04-database.md](04-database.md), [01-architecture.md](01-architecture.md#system-overview)

---

## ADR-002: Why UUID

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Offline-first clients create records without server contact. Auto-increment integers collide when two devices create invoices or parties simultaneously. Sync must merge records without ID remapping.

### Decision

Use **UUID v4** primary keys for all synced business entities. Sequential `document_number` is separate from PK.

### Consequences

**Positive:**

- Client-generated IDs safe for offline creates
- No ID remapping on sync — reduces complexity and bugs
- Globally unique references in `inventory_movements.reference_id` and `ledger_entries.reference_id`

**Negative:**

- Larger indexes than integers (16 bytes vs 4–8)
- UUIDs are not human-readable — UI uses `document_number` for display
- Random UUIDs reduce index locality vs sequential IDs (acceptable at Phase 1 scale)

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Auto-increment (server only) | Offline creates cannot obtain next ID without network |
| Composite device prefix + local counter | Fragile; harder to query and index |
| ULID | Valid option; UUID v4 sufficient and widely supported in Flutter/Node |

**References:** [04-database.md](04-database.md#primary-keys), [04-database.md](04-database.md#uuid-strategy)

---

## ADR-003: Why Modular Monolith

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Phase 1 team is small. The PRD covers many domains (sales, purchases, inventory, parties, accounting, reports) but deployment and operational complexity must stay low for MVP velocity.

### Decision

Build a **modular monolith** — single Fastify deployable with domain-aligned modules (`auth`, `sales`, `parties`, etc.). No microservices in Phase 1.

### Consequences

**Positive:**

- Single deployment, single database, simple debugging
- Module boundaries match business domains — extraction path exists if needed
- Shared transactions across domains (finalize invoice touches Sales + Inventory + Accounting)
- Lower infrastructure cost for MVP

**Negative:**

- All modules scale together horizontally (acceptable at Phase 1 load)
- Discipline required to prevent cross-module spaghetti — enforced via dependency rules

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Microservices | Operational overhead exceeds team capacity for MVP |
| Serverless functions | Poor fit for long sync batches and transactional finalize flows |
| Separate sync service | Premature; Sync module within monolith is sufficient |

**References:** [01-architecture.md](01-architecture.md#bounded-contexts), [01-architecture.md](01-architecture.md#module-responsibilities)

---

## ADR-004: Why REST

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

The API serves Flutter clients performing batch sync, CRUD operations, and occasional cloud-only actions (bootstrap, webhooks). Real-time POS does not depend on the API.

### Decision

Use **REST** over HTTP with JSON. Base path `/api/v1`. WebSockets deferred to future phase.

### Consequences

**Positive:**

- Predictable resource URLs for each entity group
- Batch sync via `/sync/push` and `/sync/pull` fits REST naturally
- Easy to test, document, and debug
- CDN and standard HTTP tooling compatible

**Negative:**

- No built-in real-time push — Nazdikwala orders use webhook + sync pull in Phase 1
- Multiple round trips for complex reads — mitigated by client SQLite as primary read path

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| GraphQL | Added complexity; sync batch model doesn't benefit from flexible queries |
| gRPC | Poor browser/tooling fit; Flutter support adds friction |
| WebSockets (primary) | POS is offline-first; REST sufficient for sync cadence |

**References:** [05-api.md](05-api.md), [05-api.md](05-api.md#future-websocket-strategy)

---

## ADR-005: Why Drizzle

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

The API needs type-safe PostgreSQL access on NeonDB, schema migrations, and SQL-transparent queries for ERP reports (GSTR, day book, ledger). Team uses TypeScript with Fastify and Bun. Prisma was initially considered but rejected for better SQL control and lighter runtime.

### Decision

Use **Drizzle ORM** with **Drizzle Kit** for schema definitions, migrations, and queries. Schema lives in `src/db/schema/`; migrations in `drizzle/migrations/`.

### Consequences

**Positive:**

- SQL-like query builder — complex reports use raw SQL or Drizzle joins without abstraction leak
- Lightweight runtime; fits Bun and long-running sync workers
- `drizzle-kit generate` / `migrate` integrates with NeonDB
- Zod integration via `drizzle-zod` for API validation alignment
- Schema is TypeScript — same language as services

**Negative:**

- Client uses Drift — two schemas must be kept in sync manually against [04-database.md](04-database.md)
- Migration UX less visual than Prisma Studio — `drizzle-kit studio` for dev

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Prisma | Heavier runtime; opaque SQL for complex GST reports; superseded |
| Raw SQL + pg | No type safety at 40+ tables |
| TypeORM | Less active ecosystem for new TypeScript projects |

**References:** [04-database.md](04-database.md#migration-strategy), [01-architecture.md](01-architecture.md#technology-decisions)

---

## ADR-006: Why Flutter

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

PRD targets **desktop (Windows, macOS)** as primary platform with **mobile (Android, iOS)** support. POS requires keyboard-first operation, fast rendering, and offline SQLite. Vyapar-inspired UI must feel native on desktop.

### Decision

Use **Flutter** for the client with Riverpod, GoRouter, and Drift.

### Consequences

**Positive:**

- Single codebase for four platforms — critical for small team
- Strong desktop support for keyboard POS (Tab, Enter, F-keys, Alt shortcuts)
- Drift provides type-safe SQLite — aligns with offline-first
- Rich widget ecosystem for sparklines, drag-and-drop dashboard widgets

**Negative:**

- Flutter desktop still maturing — occasional platform-specific issues
- Larger app binary than native
- Team must learn Dart if not already familiar

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| React Native | Desktop support insufficient for primary POS use case |
| Electron + web | Higher memory footprint; offline SQLite less integrated |
| Native per platform | 4× development and maintenance cost |
| .NET MAUI | Smaller mobile ecosystem in target market |

**References:** [01-architecture.md](01-architecture.md#client-architecture), [00-project.md](00-project.md)

---

## ADR-007: Offline First

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

PRD explicitly requires offline-first resilience: shopkeepers execute 50+ daily transactions, often with spotty internet. Sync indicator shows "Offline (Saving locally)" as normal state. POS must never block on network.

### Decision

**Offline-first architecture:** SQLite on device is the write path for all POS and billing operations. Cloud sync runs in background. API scope is auth, sync, backup — not real-time POS.

### Consequences

**Positive:**

- Uninterrupted billing during network outages — core PRD requirement
- Sub-millisecond local reads for omni-search and POS
- Graceful degradation — app fully functional offline

**Negative:**

- Sync complexity: conflict resolution, tombstones, schema versioning
- Two databases to maintain (Drift + Drizzle)
- Initial bootstrap download can be large for established businesses

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Online-first with local cache | Network dependency violates PRD; POS fails when offline |
| Read offline / write online | Writes blocked without network — unacceptable for billing |
| PouchDB/CouchDB sync | Less control over conflict rules and Indian ERP domain logic |

**References:** [01-architecture.md](01-architecture.md#offline-sync-overview), [05-api.md](05-api.md#offline-sync-api)

---

## ADR-008: Soft Delete

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Deleted records must propagate to all synced devices. Hard deletes cause orphan references in offline queues and ledger audit trails. GST compliance requires transaction history retention.

### Decision

Use **soft delete** via `deleted_at` timestamp on all mutable business entities. Sync propagates tombstones.

### Consequences

**Positive:**

- Remote devices receive delete events via sync pull
- Audit and compliance — historical reports still reference deleted parties/items
- Recoverable mistakes — unset `deleted_at` if needed (owner action)

**Negative:**

- Queries must filter `deleted_at IS NULL` consistently
- Unique constraints may need partial indexes `(business_id, mobile) WHERE deleted_at IS NULL`
- Storage grows — acceptable; archived data compresses well

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Hard delete + sync delete op only | Offline devices may miss delete if sync fails; orphans remain |
| Archive tables | Doubles schema complexity for marginal benefit in Phase 1 |
| Status flag `is_deleted` | Equivalent to `deleted_at`; timestamp enables conflict ordering |

**References:** [04-database.md](04-database.md#soft-delete), [04-database.md](04-database.md#sync-metadata)

---

## ADR-009: Single Source of Truth

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Dual-database architecture risks confusion about which store is authoritative for operational vs cloud data. PRD Section 10 describes cloud as integration hub, but POS must not depend on cloud latency.

### Decision

| Context | Source of truth |
|---------|-----------------|
| **Operational (POS, billing)** | Local SQLite on each device |
| **Multi-device reconciliation** | PostgreSQL after successful sync push |
| **Backup / disaster recovery** | PostgreSQL |
| **Nazdikwala catalog** | PostgreSQL → outbound sync to marketplace |

Local writes are immediate. Cloud reconciles on sync. Conflict resolution: last-write-wins with version check; stock reconciled from movement ledger.

### Consequences

**Positive:**

- Clear mental model for engineers: write local, sync cloud
- POS latency independent of network
- Cloud remains integration point for Nazdikwala without blocking sales

**Negative:**

- Brief inconsistency between devices until sync completes
- Engineers must never read PostgreSQL for client UI logic

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Cloud as sole source of truth | POS blocked without network |
| Eventual consistency without version | Harder to detect and resolve conflicts |
| Per-entity source assignment | Too complex for team and debugging |

**References:** [01-architecture.md](01-architecture.md#architecture-principles), [01-architecture.md](01-architecture.md#offline-sync-overview)

---

## ADR-010: Business Domain Separation

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Billing Baba spans sales, purchases, inventory, parties, accounting, payments, and reports. Without clear boundaries, business logic leaks into widgets and route handlers — unmaintainable for an ERP.

### Decision

Organize code by **business domain** — not by screen or technical layer alone.

**Backend:** `src/modules/{domain}/` with routes, services, db per module.

**Client:** `lib/features/{domain}/` with presentation, domain, data layers.

Domains: Identity, Business, CRM, Inventory, Sales, Purchases, Accounting, Reports, Settings, Notifications, Sync.

Payments belong to the **Accounting** domain (module `accounting`). Catalog capabilities belong to **Inventory** (module `inventory`).

Cross-domain calls go through **service interfaces** only. Routes and widgets stay thin.

### Consequences

**Positive:**

- Parallel development — teams can own domains
- Testable services isolated from HTTP and UI
- Extraction to microservices possible at module boundaries
- Aligns with PRD feature groupings

**Negative:**

- Requires discipline — shared utilities must not become a junk drawer
- Some workflows cross domains (finalize invoice) — orchestration in Sales service with explicit Inventory/Accounting calls

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Layer-only structure (`controllers/`, `models/`) | Domains scattered; hard to navigate ERP-scale codebase |
| Screen-based features only | Duplicates catalog logic across sales and purchases screens |
| Shared anemic domain model | Business rules spread across handlers |

**References:** [01-architecture.md](01-architecture.md#business-domains), [01-architecture.md](01-architecture.md#dependency-rules), [06-coding-standards.md](06-coding-standards.md)

---

## ADR-011: Why Fastify

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

The API requires a performant Node.js HTTP framework for REST endpoints, JWT auth, rate limiting, and modular routing aligned to business domains. Runtime is **Bun** for development and production scripts.

### Decision

Use **Fastify** with TypeScript for the REST API server.

### Consequences

**Positive:**

- High throughput for sync batch endpoints
- Schema-based validation via `@fastify/type-provider-typebox` or Zod wrappers
- Plugin ecosystem: JWT, CORS, rate limit, Swagger
- Modular routing via encapsulated plugins per domain module
- Native Bun compatibility with `tsx` / Bun runtime

**Negative:**

- Different plugin patterns than Express — team onboarding required
- Must use async handlers consistently

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Express | Slower; less schema-native validation; Fastify chosen for sync throughput |
| Hono | Smaller plugin ecosystem for ERP middleware needs |
| NestJS | DI overhead excessive for modular monolith MVP |

**References:** [01-architecture.md](01-architecture.md#backend-architecture), [05-api.md](05-api.md)

---

## ADR-012: Why Drift

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Offline-first requires type-safe SQLite access on Flutter with migrations, queries, and schema parity with cloud PostgreSQL. Raw `sqflite` lacks compile-time safety at ERP scale.

### Decision

Use **Drift** (formerly Moor) as the Flutter SQLite ORM with code-generated DAOs and migrations.

### Consequences

**Positive:**

- Type-safe queries and compile-time table definitions
- Migration system mirrors Drizzle Kit workflow on cloud
- Stream-based queries for reactive UI (Riverpod integration)
- Strong SQLite performance on desktop and mobile

**Negative:**

- Code generation step in build pipeline
- Schema must be manually kept in sync with Drizzle cloud schema
- Learning curve for developers new to Drift

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| sqflite raw | No type safety; unmaintainable at 40+ tables |
| Isar | Different query model; less SQL-transparent for report queries |
| Hive | Not relational — unsuitable for ERP joins and ledger |

**References:** [04-database.md](04-database.md), [ADR-007](09-decisions.md#adr-007-offline-first)

---

## ADR-013: Why Riverpod

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Flutter client needs testable, composable state management across 10+ feature domains without `setState` spaghetti. POS and dashboard require granular rebuilds and provider composition.

### Decision

Use **Riverpod** for all application and feature state. GoRouter for navigation.

### Consequences

**Positive:**

- Compile-safe provider references
- Easy testing — override providers in widget tests
- `AsyncValue` pattern for loading/error/empty states (PRD requirement)
- Provider composition for cross-domain dashboard reads

**Negative:**

- Team must avoid business logic in providers — delegate to services
- Riverpod 2.x patterns require onboarding

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Bloc | More boilerplate for CRUD-heavy ERP screens |
| Provider | Less compile safety than Riverpod |
| setState | Forbidden for feature state per architecture rules |

**References:** [01-architecture.md](01-architecture.md#client-architecture), [06-coding-standards.md](06-coding-standards.md)

---

## ADR-014: Unified Sales Documents

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

PRD defines seven outward document types (estimate, challan, tax invoice, bill of supply, normal invoice, POS, sales return) sharing identical structure: header, lines, party, tax, totals, conversion chain. Separate tables per type would duplicate schema, sync, and API surface.

### Decision

Single polymorphic table `sales_documents` with `document_type` enum and shared `sales_document_lines`. POS uses `document_type = pos` with optional `pos_session_id`.

### Consequences

**Positive:**

- One API resource (`/sales-documents`) with type filter
- Unified sync entity type
- Convert estimate→invoice, challan→invoice, kaccha→pakka via `converted_from_id` without cross-table joins
- Single index strategy for omni-search by document number

**Negative:**

- Some columns nullable depending on type (e.g. `party_id` for walk-in POS)
- Service layer must enforce per-type rules (stock impact, GST formalization)

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Table per document type | 7 header + 7 line tables; sync and API duplication |
| Single table without type enum | Cannot enforce per-type business rules |
| JSON lines embedded in header | Poor query performance for GSTR line reports |

**References:** [04-database.md](04-database.md#sales_documents), [05-api.md](05-api.md#sales-apis)

---

## ADR-015: Unified Purchase Documents

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

PRD defines purchase orders, purchase bills, and purchase returns with shared header/line structure. Expenses are separate (non-inventory operational costs) but remain in Purchases domain.

### Decision

Single polymorphic table `purchase_documents` with `document_type` enum and shared `purchase_document_lines`. Expenses use separate `expenses` table.

### Consequences

**Positive:**

- Mirrors sales document pattern — consistent mental model
- One finalize flow with type-specific stock and ledger rules
- Reduced migration and sync surface

**Negative:**

- Purchase orders and bills share table — status/type guards required in service layer

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Separate tables per purchase type | Duplication without distinct schema needs |
| Merge expenses into purchase_documents | Expenses have no line items or supplier invoice structure |

**References:** [04-database.md](04-database.md#purchase_documents), [05-api.md](05-api.md#purchase-apis)

---

## ADR-016: Event-based Inventory Ledger

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

Multi-device offline sync causes stock quantity conflicts. Updating `stock_levels.quantity` directly loses audit history and makes reconciliation impossible. PRD requires opening stock, movement tracking, and FIFO/average valuation.

### Decision

Use append-only **`inventory_movements`** as the stock event ledger. `stock_levels` is a **derived cache** updated on each movement. Sync conflicts reconcile by replaying movements.

### Consequences

**Positive:**

- Full audit trail — every sale, purchase, return, challan, adjustment recorded
- Conflict resolution replays movement ledger instead of overwriting quantity
- Supports per-godown stock with `godown_id` on movements
- GSTR and stock valuation reports query movements for cost basis

**Negative:**

- Must never update or delete movements — only append
- `stock_levels` can drift if update fails — periodic reconciliation job recommended

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Update stock_levels only | No audit; sync conflicts corrupt quantity |
| stock_movements name | Renamed to `inventory_movements` for domain clarity |
| Event sourcing full replay on every read | Too slow for POS; cache `stock_levels` for reads |

**References:** [04-database.md](04-database.md#inventory_movements), [01-architecture.md](01-architecture.md#event-flow-diagram)

---

## ADR-017: Double Entry Accounting

| Field | Value |
|-------|-------|
| **Date** | June 2026 |
| **Status** | Accepted |
| **Author** | Technical Lead |

### Context

PRD requires party ledger, receivable/payable tracking, day book, GSTR, and P&L. Indian B2B shops expect Vyapar-style running balances per party. Single-column "amount" fields cannot represent debit/credit semantics.

### Decision

Use **`ledger_entries`** with explicit `debit` and `credit` columns. Each entry has exactly one non-zero side. Party running balance in `balance_after`. Payments post credit against receivable; sales post debit.

Phase 1 uses **single-sided party ledger** (not full GL with account heads). Cash/bank tracked via `payment_mode` enum — no separate cash/bank account tables.

### Consequences

**Positive:**

- Vyapar-compatible party ledger and day book
- Clear receivable (debit balance) vs payable (credit balance) semantics
- GSTR and P&L aggregate from ledger and documents
- Append-only — no mutation of posted entries

**Negative:**

- Not full double-entry with chart of accounts — sufficient for Phase 1 SME scope
- `balance_after` must be computed transactionally to avoid races

### Alternatives Considered

| Alternative | Rejected because |
|-------------|------------------|
| Single `amount` signed column | Ambiguous for reports; poor Vyapar parity |
| Full chart of accounts | PRD does not require GL accounts in Phase 1 |
| Separate cash/bank tables | PRD payment modes sufficient; adds scope |

**References:** [04-database.md](04-database.md#ledger_entries), [05-api.md](05-api.md#accounting-apis)

---

## ADR Template

Use for future decisions. Do not remove.

### ADR-<ID>: <Title>

| Field | Value |
|-------|-------|
| **Date** | `<DATE>` |
| **Status** | Proposed / Accepted / Deprecated / Superseded |
| **Author** | `<TEAM_MEMBER>` |

#### Context

What problem or situation requires a decision?

#### Decision

What was decided?

#### Consequences

What becomes easier or harder?

#### Alternatives Considered

What else was evaluated and why rejected?
