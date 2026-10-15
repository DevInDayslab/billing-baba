# GST Reports v2 — Architecture

API module: `apps/api/src/modules/gst-reports/` mounted at `/api/v1/reports/gst/*`.

## Layout

| Path | Role |
|------|------|
| `core/` | Money (paise), IST periods/FY, classifier, warnings, UQC, place of supply |
| `data/gst-data.repository.ts` | Single query layer for finalized sales/purchases + lines |
| `reports/*.calculator.ts` | Pure report builders (envelope in/out) |
| `exports/gstn-*.mapper.ts` | Best-effort GSTN offline JSON |
| `gst-reports.service.ts` | Period resolution + calculator orchestration |

Client: definition-driven UI under `apps/client/lib/features/reports/gst/` and `GstReportScaffold`.

## Response envelope

All v2 endpoints return `{ meta, sections[], totals, warnings[] }` inside the standard `{ data }` wrapper.

## Add a report in 5 steps

1. Add calculator in `reports/` and unit tests under `apps/api/tests/unit/gst-reports/`.
2. Wire method in `gst-reports.service.ts` and route in `gst-reports.routes.ts`.
3. Add `GstReportType` value + endpoint in `api_endpoints.dart`.
4. Add section/column definitions in `gst/definitions/gst_report_definitions.dart`.
5. Register nav in `gst_report_subsection.dart` (desktop + mobile registry).

## Known limitations

RCM, ITC reversals, composition scheme, export supply UI, cess until persisted on all forms, offline local reports, GSTN JSON vs portal utility parity.
