# API

## API Overview

| Property | Value |
|----------|-------|
| Framework | Fastify |
| Base URL (development) | <!-- TBD --> |
| Base URL (production) | <!-- TBD --> |
| Format | JSON |

## Domains

The API supports the following functional areas. Endpoints will be defined during development.

| Domain | Purpose |
|--------|---------|
| Authentication | User login, token management |
| Synchronization | Push and pull local changes between client and cloud |
| Cloud Backup | Backup and restore business data |
| Products | Product and inventory management |
| Customers | Customer records |
| Invoices | Billing and invoicing |
| Reports | Business reporting |

## Authentication

| Method | Header |
|--------|--------|
| Bearer token | `Authorization: Bearer <token>` |

For the full auth flow, see [01-architecture.md](01-architecture.md#authentication-flow).

## Endpoint Template

> Copy this template for each endpoint when defined.

### `<METHOD> /path/to/resource`

**Description:**

**Authentication:** Required / Optional / None

**Request:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| | | | |

**Response:** `200 OK`

**Errors:** See conventions below.

---

## Conventions

- **Content-Type:** `application/json`
- **Dates:** ISO 8601
- **Pagination:** `?page=1&limit=20`
- **Single resource:** `{ "data": { ... } }`
- **Collection:** `{ "data": [...], "meta": { "page", "limit", "total" } }`
- **Errors:** `{ "error": { "code", "message" } }` — use standard HTTP status codes
