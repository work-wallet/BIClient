# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows Keep a Changelog principles (dates in YYYY-MM-DD). Version numbers align with assembly versions unless otherwise noted.

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
