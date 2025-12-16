# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows Keep a Changelog principles (dates in YYYY-MM-DD). Version numbers align with assembly versions unless otherwise noted.

## [4.4.0] - Unreleased

### Added (4.4.0)

- Permits: add support for the new workflow component types.
- PPE: add support for the new PPE custom fields (properties).
- PPE: PPE Group's are now captured against PPE Types.

### Changed (4.4.0)

- Actions: add the email address for the person an action is assigned to.
- Assets: add support for the new shared custom properties (shared across all asset types).
- Permits: support the new permit `Extended` status.

## [4.3.0] - 2025-12-09

### Added (4.3.0)

Major:

- New datasets: `AssetInspections`, `AssetObservations` (schema + ingestion + inclusion in Assets Power BI model).

Minor:

Associated contact import added across existing datasets:

- Assets: `AssetAssignment` contact (person asset assigned to).
- ReportedIssues: `ReportedBy` contact (who reported the issue/incident).
- SafetyCards: associated `Employee` contact.
- Inductions: `InductionTaken` contact (who took the induction).

### Changed (4.3.0)

- Assets Power BI sample extended to surface inspections and observations.
- Assets dataset property types expanded (`AssetPropertyType`): `Date`, `Time`, `DateTime`.
- Supports optional `beta` flag to enable pre-release API extraction.
- Enriched `Context` blocks from API are now read and processed.
- Units (units of measure) reference data expanded with additional values.
- Documentation improvements: sample JSON + reference data sections clarified and expanded.
- All reset stored procedures replaced by consolidated `DeleteAllData` stored procedure.
- All Power BI sample reports now use the default Power BI theme.

## [4.2.0] - 2025-10-09

### Added (4.2.0)

- Actions dataset: new `OriginalDueOn` field (Power BI model column labelled "Original Due On").
- Sample API response JSON file and associated reference data documentation.

### Changed (4.2.0)

- API resilience: refactored data extraction using Polly / `Microsoft.Extensions.Http.Resilience` with retry/backoff handling for HTTP 429 and dynamic page size adjustment on HTTP 400 (page size too large).
- Pagination logic updated to capture first page `SynchronizationVersion` ensuring accurate change detection across paged responses.
- Documentation overhaul: architecture & data flow overview, direct API guidance, scheduling & idempotency recommendations, README section restructuring + table of contents.
- All NuGet packages upgraded (including `Microsoft.Data.SqlClient` to 6.1.2).
- Power BI sample projects migrated to latest `.pbip` format; Actions model diagrams updated.

### Fixed (4.2.0)

- Null comparison logic in `mart.ETL_MaintainPPETypeDimension`.

## [4.1.0] - 2025-08-28

### Added (4.1.0)

- New PPE datasets: `PPEStocks`, `PPEStockHistories`, `PPEAssignments`.
- Full schema objects (tables, types, stored procedures) for PPE.
- PPE Power BI sample project.

### Changed (4.1.0)

- Migrated JSON handling from Newtonsoft.Json to System.Text.Json for performance.
- Upgraded all NuGet package dependencies.
- Updated existing Power BI sample projects to latest format.

## [4.0.4] - 2025-07-14

### Added (4.0.4)

- Reported Issues dataset: "Reported By Company" field (formatted `name (company)`).

### Fixed (4.0.4)

- Power BI slicer bug for Reported Issues when switching between reporting and investigation stages.

### Changed (4.0.4)

- General NuGet dependency upgrades.

## [4.0.3] - 2025-05-26

### Added (4.0.3)

- Audits dataset: contextual fields per question: `Section`, `OrderInSection` across relevant audit question tables.

### Changed (4.0.3)

- NuGet dependency upgrades.

## [4.0.2] - 2025-05-08

### Fixed (4.0.2)

- Asset status changes not propagating to database (reprocessing logic corrected).

## [4.0.1] - 2025-04-30

### Changed (4.0.1)

- Increased maximum length of `AuditScoreSection.Section` column.

### Removed (4.0.1)

- Site Audits (legacy) ingestion path deprecated (tables retained, module not processed going forward).

## [4.0.0] - 2025-04-19

### Added (4.0.0)

- Initial release of new Audits module (foundation schema) prior to 4.0.1 refinements.
- Multi-region support via `DataRegion` header.
- Configurable dataset selection in `appsettings.json`.

### Changed (4.0.0)

- Improved console logging clarity.

## [3.2.1] - 2024-10-27

### Added (3.2.1)

- Post-processing placeholder stored procedures to simplify extension.

## [3.2.0] - 2024-10-02

### Added (3.2.0)

- Safety Cards module (schema + Power BI sample).
- Location external identifier support.

### Changed (3.2.0)

- Standardised SiteAudits JSON context header to align with other datasets.
- SQL script readability / formatting improvements.

### Fixed (3.2.0)

- `LastSynchronizationVersion` handling: ensures `ETL_ChangeDetection` updates even when zero rows returned, reducing risk of stale version errors.

## [3.1.3] - 2024-08-01

### Changed (3.1.3)

- Consistent use of SQL MERGE patterns for dimension maintenance.
- Documentation: initial direct API calling guidance added.

### Added (3.1.3)

- Power BI project files incorporated into repository.

## [3.1.2] - 2024-07-29

### Added (3.1.2)

- Published build artifacts (binaries) for distribution at version 3.1.2.

## [3.1.1] - 2024-05-08

### Changed (3.1.1)

- Migrated all C# projects to .NET 8.0.
- Azure Function moved from in‑process to isolated worker model.

## [3.1.0] - 2024-01-17

### Added (3.1.0)

- Assets module: assets, assignments, and custom field (property) support.

### Notes (3.1.0)

- Asset inspection histories and defect reports not yet included.

## [3.0.0] - 2023-10-25

### Added (3.0.0)

- Multiple wallet processing support (Console + Function).

### Changed (3.0.0)

- Configuration model updates to support wallet arrays (breaking for <3.0.0 without config adjustment).

## [2.0.1] - 2023-10-05

### Added (2.0.1)

- Initial release as a public git repo.

---

Earlier versions (<2.0.1) are not documented here.

---
