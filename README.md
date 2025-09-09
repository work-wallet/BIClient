# Work Wallet Business Intelligence (BI) Client

A streamlined, production-ready reference implementation for extracting Health & Safety data from the Work Wallet BI Extract API into a local/star-schema SQL Server data mart, with optional scheduling (console or Azure Function) and sample Power BI semantic models.

---

## Contents

1. [Overview](#overview)
2. [Supported Datasets](#supported-datasets)
3. [Quick Start](#quick-start)
4. [Prerequisites](#prerequisites)
5. [Architecture](#architecture)
6. [Repository Structure](#repository-structure)
7. [API Access](#api-access)
8. [Binaries / Downloads](#binaries--downloads)
9. [Database Deployment](#database-deployment)
10. [Data Extraction (Console)](#data-extraction-console)
11. [Azure Function Deployment](#azure-function-deployment)
12. [Force Data Reset](#force-data-reset)
13. [Power BI Samples](#power-bi-samples)
14. [Configuration Reference](#configuration-reference)
15. [Troubleshooting](#troubleshooting)
16. [Security Notes](#security-notes)
17. [Contributing / Issues](#contributing--issues)
18. [License](#license)

---

## Overview

The [Work Wallet](https://www.work-wallet.com/) Health & Safety platform exposes a secure BI Extract API optimised for regular, incremental data feeds into analytics platforms. This repository provides:

- A ready-made SQL Server data mart (star schema) and deployment tool
- A robust, paged, change-tracking extraction client (console + Azure Function)
- Sample Power BI project (.pbip) files with semantic models & reports
- Extensible, strongly-typed .NET 8 code you can adopt or adapt

You can use the binaries directly (no code changes required), customise the solution, or treat it as a reference implementation for your own stack.

## Supported Datasets

The API currently enables download of:

- Reported Issues
- Inductions
- Permits
- Actions
- Assets
- Safety Cards
- Audits
- PPE (three modules):
  - PPEStocks
  - PPEStockHistories
  - PPEAssignments

Each dataset is queried using paging + `lastSynchronizationVersion` change tracking to minimise transfer volume.

## Quick Start

1. Request API access (see [API Access](#api-access)).
2. Download latest release binaries (database deploy + client) from [Releases](https://github.com/work-wallet/BIClient/releases).
3. Deploy / upgrade the database (edit `WorkWallet.BI.ClientDatabaseDeploy/appsettings.json` then run `WorkWallet.BI.ClientDatabaseDeploy.exe`).
4. Configure data extraction (edit `WorkWallet.BI.ClientSample/appsettings.json` then run the executable — first run is a full load).
5. (Optional) Open a Power BI sample `.pbip` project from `PowerBISamples`, point to your database, refresh.
6. (Optional) Deploy `WorkWallet.BI.ClientFunction` for scheduled automation.

## Prerequisites

You should be comfortable with basic SQL Server administration and .NET runtime deployment.

Required:

- SQL Server (Azure SQL, LocalDB, Express, Developer, Standard, etc.)
- A SQL connection string compatible with `Microsoft.Data.SqlClient`
- Internet access (firewall allow: `bi.work-wallet.com`, `identity.work-wallet.com`)
- .NET 8 runtime (for running) or SDK (if building from source)

Optional:

- Visual Studio 2022 (or `dotnet` CLI) to modify/build
- Power BI Desktop (for provided sample models)
- Azure Subscription (if using Azure Functions)

## Architecture

Core concepts:

- OAuth2 Client Credentials → bearer tokens from `https://identity.work-wallet.com`
- Paged API requests to `https://bi.work-wallet.com/dataextract/{dataset}` (page size configurable; max 500)
- Incremental sync keyed by `lastSynchronizationVersion` persisted in `mart.ETL_ChangeDetection`
- Star-schema data mart (facts + dimensions) populated via JSON shredding stored procedures
- Multiple wallet support via `AgentWallets[]` configuration array

## Repository Structure

| Project | Purpose |
| --- | --- |
| `WorkWallet.BI.ClientDatabaseDeploy` | Deploys / upgrades schema, types & stored procedures (drops + recreates procs on upgrade). |
| `WorkWallet.BI.ClientSample` | Console data extraction client (manual / scheduled). |
| `WorkWallet.BI.ClientFunction` | Azure Function timer-trigger wrapper for automated extraction. |
| `WorkWallet.BI.ClientCore` | Shared abstractions & options. |
| `WorkWallet.BI.ClientServices` | HTTP + data store implementations, processor logic. |
| `PowerBISamples` | `.pbip` models & reports (one per dataset family + theme). |
| `Docs` | API, schema notes, legacy migration, semantic model diagrams. |

## API Access

Access is enabled per Wallet. Contact Work Wallet Support to request activation. You will receive:

- `ApiAccessClientId`
- `ApiAccessClientSecret`
- `WalletId`
- `WalletSecret`

Base endpoints:

- API: `https://bi.work-wallet.com`
- Auth: `https://identity.work-wallet.com`

Direct integration details: see [`Docs/API.md`](./Docs/API.md).

## Binaries / Downloads

All binaries target .NET 8. Install the [.NET 8 runtime](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) if not already present.

Download from GitHub [Releases](https://github.com/work-wallet/BIClient/releases):

| Tool | Executable | Config File |
| --- | --- | --- |
| Database Deployment | `WorkWallet.BI.ClientDatabaseDeploy.exe` | `appsettings.json` |
| Data Extraction (Console) | `WorkWallet.BI.ClientSample.exe` | `appsettings.json` |

## Database Deployment

Executable: `WorkWallet.BI.ClientDatabaseDeploy`.

1. (Legacy) If upgrading from an installation prior to Aug 2023 read [`Docs/LegacySchema.md`](./Docs/LegacySchema.md) first.
2. Edit `appsettings.json` → set: `AppSettings:DatabaseConnectionString`.
3. Run `WorkWallet.BI.ClientDatabaseDeploy.exe` – creates the database if absent and applies migrations (drops & recreates stored procedures in `mart` schema intentionally).

## Data Extraction (Console)

Executable: `WorkWallet.BI.ClientSample`.

Edit `appsettings.json` (key fields shown):

| Path | Description |
| --- | --- |
| `ClientOptions:ApiAccessClientId` | OAuth2 client id |
| `ClientOptions:ApiAccessClientSecret` | OAuth2 client secret |
| `ClientOptions:AgentWallets:[n]:WalletId` | Wallet identifier (repeatable) |
| `ClientOptions:AgentWallets:[n]:WalletSecret` | Wallet secret (repeatable) |
| `ClientOptions:DataSets[]` | Array of datasets to pull (see list above) |
| `ConnectionStrings:ClientDb` | SQL connection string |

Run the executable manually or schedule (Task Scheduler / cron / etc.).

Notes:

- First run performs full historical load (may be large).
- Incremental loads fetch only changed pages per dataset.
- Progress & change tracking stored in `mart.ETL_ChangeDetection`.
- Configure multiple wallets by adding more objects to `AgentWallets[]`.

Error `Invalid lastSynchronizationVersion`: usually means extraction gap exceeded retention. Resolve by [Force Data Reset](#force-data-reset).

## Azure Function Deployment

Project: `WorkWallet.BI.ClientFunction` (timer trigger).

Recommended host creation settings:

- Runtime stack: .NET 8 (Isolated)
- OS: Windows
- Application Insights: Enabled

Key app settings:

| Setting | Example | Notes |
| --- | --- | --- |
| `BITimerTriggerSchedule` | `0 30 21 * * *` | NCRONTAB expression (UTC) |
| `FuncOptions:AgentApiUrl` | `https://bi.work-wallet.com` | Base API URL |
| `FuncOptions:AgentPageSize` | `500` | Max recommended 500 |
| `FuncOptions:AgentWallets:[0]:WalletId` | | Repeat per wallet |
| `FuncOptions:AgentWallets:[0]:WalletSecret` | |  |
| `FuncOptions:ApiAccessAuthority` | `https://identity.work-wallet.com` | Auth endpoint |
| `FuncOptions:ApiAccessClientId` | |  |
| `FuncOptions:ApiAccessClientSecret` | |  |
| `FuncOptions:ApiAccessScope` | `ww_bi_extract` | Scope constant |
| `sqldb_connection` | | SQL connection string |

Local development requires `local.settings.json` (sample retained and updated in repo). Include `APPLICATIONINSIGHTS_CONNECTION_STRING` if you want to see structured logs (some info-level events bypass console output).

## Force Data Reset

Only perform if you need a full re-pull (e.g. lost change tracking continuity).

Mechanism: Delete relevant rows from `mart.ETL_ChangeDetection`. On next run the client will:

1. Truncate (delete) data rows for affected dataset tables
2. Re-ingest from page 1

Example (reset Audits dataset):

```sql
DELETE FROM mart.ETL_ChangeDetection WHERE LogType = 'AUDIT2_UPDATED';
```

| Dataset | LogType |
| --- | --- |
| ReportedIssues | REPORTED_ISSUE_UPDATED |
| Inductions | INDUCTION_UPDATED |
| Permits | PERMIT_UPDATED |
| Actions | ACTION_UPDATED |
| Assets | ASSET_UPDATED |
| SafetyCards | SAFETY_CARD_UPDATED |
| Audits | AUDIT2_UPDATED |
| PPEStocks | PPE_STOCK_UPDATED |
| PPEStockHistories | PPE_STOCK_HISTORY_UPDATED |
| PPEAssignments | PPE_ASSIGNMENT_UPDATED |

If large volumes make deletion slow, recreating the database + redeploying may be faster.

## Power BI Samples

Sample Power BI Project files (`.pbip`) are located in `PowerBISamples/` (one folder per domain). These include both the semantic model and report definitions.

You may:

- Point them at your database (change data source)
- Refresh to populate visuals
- Customise measures, relationships, visuals

They are a reference only—any BI tool can consume the database.

For model diagrams see [`Docs/PowerBISamplesModels.md`](Docs/PowerBISamplesModels.md).

### Connect to Your Database

Power BI Desktop → File → Options and settings → Data source settings → Change Source...

![Power BI Options and Settings](Docs/Images/PowerBIOptionsAndSettings.png)

![Power BI Data Source Settings](Docs/Images/PowerBIDataSourceSettings.png)

### Refresh Data

Click Refresh (Home ribbon). Data is on-demand unless you publish to a service (Power BI Pro / Fabric) with scheduled refresh.

![Power BI Refresh Data](Docs/Images/PowerBIRefresh.png)

### Adjust Filters

Ensure any default filters (e.g. date, site, status) reflect values present in your Wallet or visuals may appear blank.

## Configuration Reference

Common console `appsettings.json` keys:

| Key | Purpose |
| --- | --- |
| `ClientOptions:ApiAccessClientId` | OAuth2 client credential id |
| `ClientOptions:ApiAccessClientSecret` | OAuth2 client credential secret |
| `ClientOptions:ApiAccessAuthority` | (`identity.work-wallet.com`) override if needed |
| `ClientOptions:ApiAccessScope` | Should be `ww_bi_extract` |
| `ClientOptions:AgentApiUrl` | API base (default `https://bi.work-wallet.com`) |
| `ClientOptions:AgentPageSize` | Page size (<= 500) |
| `ClientOptions:AgentWallets` | Array of wallet credential objects |
| `ClientOptions:DataSets` | Array of dataset names to process |
| `ConnectionStrings:ClientDb` | Target SQL database |

## Troubleshooting

| Symptom | Cause | Resolution |
| --- | --- | --- |
| `Invalid lastSynchronizationVersion` | Gap too long / table reset mismatch | Perform [Force Data Reset](#force-data-reset). |
| Slow first run | Full historical ingestion | Allow to complete; subsequent runs incremental. |
| Empty Power BI visuals | Filters exclude data / wrong DB | Adjust filters; verify data tables populated. |
| Auth failure (401) | Invalid client credentials | Re-check `ApiAccessClientId` / secret; wallet enabled? |
| Network errors | Firewall / proxy blocking | Allow outbound HTTPS to API + identity endpoints. |
| High DB log growth | Large initial ingest | Ensure regular log backups (full recovery) or switch to simple during first load. |

## Security Notes

- Keep client secrets + wallet secrets out of source control (use environment variables / secret managers for production).
- Principle of least privilege: SQL login should have rights only to target database.
- All traffic is HTTPS; no extra encryption required in transit.
- Consider enabling Transparent Data Encryption (TDE) / at rest encryption in SQL if mandated.

## Contributing / Issues

Issues / enhancement requests: open a GitHub Issue. Pull Requests welcome (ensure any schema changes include deployment scripts & docs update).

## License

See [LICENSE.md](./LICENSE.md).

---

### Revision History (README)

- Updated for clarity, structure & consistency (spelling corrections, added quick start, troubleshooting, security) – Sept 2025.
