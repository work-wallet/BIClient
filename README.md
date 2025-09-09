# Work Wallet Business Intelligence (BI) Client

A streamlined, production-ready reference implementation for extracting Health & Safety data from the Work Wallet BI Extract API into a local/star-schema SQL Server data mart, with optional scheduling (console or Azure Function) and sample Power BI semantic models.

---

## Contents

1. [Overview](#overview)
2. [Supported Datasets](#supported-datasets)
3. [Usage Paths](#usage-paths)
4. [Quick Start (Database + Power BI Path)](#quick-start-database--power-bi-path)
5. [Prerequisites](#prerequisites)
6. [Architecture](#architecture)
7. [Repository Structure](#repository-structure)
8. [API Credentials](#api-credentials)
9. [Binaries / Downloads](#binaries--downloads)
10. [Database Deployment](#database-deployment)
11. [Data Extraction (Console)](#data-extraction-console)
12. [Azure Function Deployment](#azure-function-deployment)
13. [Force Data Reset](#force-data-reset)
14. [Power BI Samples](#power-bi-samples)
15. [Configuration Reference](#configuration-reference)
16. [Troubleshooting](#troubleshooting)
17. [Security Notes](#security-notes)
18. [Direct API Usage (No Database)](#direct-api-usage-no-database)
19. [Contributing / Issues](#contributing--issues)
20. [License](#license)

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

## Usage Paths

Choose the approach that best fits your analytics platform maturity:

| Path | When to Use | Outputs | Effort |
| --- | --- | --- | --- |
| Quick Start (recommended) | You want an end‑to‑end working pipeline fast | Deployed SQL star schema + optional Power BI models | Minimal configuration |
| Direct API (no database) | You already have existing data integration or lake tooling | Raw paged JSON responses | Build paging + change tracking logic |

If unsure, start with the Quick Start; you can later migrate to a bespoke ingestion using the same credentials.

Advanced raw integration details are documented near the end: see [Direct API Usage (No Database)](#direct-api-usage-no-database).

Proceed to [Quick Start (Database + Power BI Path)](#quick-start-database--power-bi-path).

## Quick Start (Database + Power BI Path)

1. Request API credentials (see [API Credentials](#api-credentials)).
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
| `Images` | Screenshots (used in documentation). |
| `Scripts` | Legacy migration script. |

## API Credentials

Access is enabled per Wallet. Contact Work Wallet Support to request activation. You will receive:

- `ApiAccessClientId`
- `ApiAccessClientSecret`
- `WalletId`
- `WalletSecret`

Base endpoints:

- API: `https://bi.work-wallet.com`
- Auth: `https://identity.work-wallet.com`

These values are required for both the Quick Start (stored in configuration) and Direct API usage (token + query parameters). Raw HTTP guidance is fully contained in this README (see [Direct API Usage](#direct-api-usage-no-database)).

## Binaries / Downloads

All binaries target .NET 8. Install the [.NET 8 runtime](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) if not already present.

Download from GitHub [Releases](https://github.com/work-wallet/BIClient/releases):

| Tool | Executable | Config File |
| --- | --- | --- |
| Database Deployment | `WorkWallet.BI.ClientDatabaseDeploy.exe` | `appsettings.json` |
| Data Extraction (Console) | `WorkWallet.BI.ClientSample.exe` | `appsettings.json` |

## Database Deployment

Executable: `WorkWallet.BI.ClientDatabaseDeploy`.

1. Edit `appsettings.json` → set: `AppSettings:DatabaseConnectionString`.
2. Run `WorkWallet.BI.ClientDatabaseDeploy.exe` – creates the database if absent and applies migrations (drops & recreates stored procedures in `mart` schema intentionally).

### Legacy Installations (Pre-Aug 2023)

Most users can skip this section.

If you originally stood up the database manually before August 2023 your schema will be missing the tracking table `dbo.SchemaVersions` used by the deployment tool to know which one-time scripts have already been applied. Running the deployment tool without seeding this table could cause it to (re)apply scripts incorrectly.

To remediate:

1. Take a backup of the existing database (recommended).
2. Open the script `Scripts/InitialiseSchemaVersions.sql` and review its contents.
3. Execute it against the target database (e.g. in SQL Server Management Studio or `sqlcmd`). It inserts baseline rows representing the current state.
4. Run `WorkWallet.BI.ClientDatabaseDeploy.exe` normally.

Why this is needed: the deployment tool records each RunOnce group (schema objects) in `dbo.SchemaVersions`. Older manual installs pre-date that mechanism. Seeding prevents duplicate creation attempts and ensures future upgrades run only delta logic.

Alternative: If a full reload is acceptable you may instead create a fresh empty database, run the deployment tool (which will create `dbo.SchemaVersions` automatically) and then perform a full data extraction.

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

Only relevant to the Quick Start (database) path when incremental tracking continuity is lost.

Mechanism: Delete relevant rows from `mart.ETL_ChangeDetection`. Next execution will:

1. Delete existing rows for that dataset’s tables.
2. Re-ingest from page 1.

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

For model diagrams see [`PowerBISamplesModels.md`](Docs/PowerBISamplesModels.md).

### Connect to Your Database

Power BI Desktop → File → Options and settings → Data source settings → Change Source...

![Power BI Options and Settings](Images/PowerBIOptionsAndSettings.png)

![Power BI Data Source Settings](Images/PowerBIDataSourceSettings.png)

### Refresh Data

Click Refresh (Home ribbon). Data is on-demand unless you publish to a service (Power BI Pro / Fabric) with scheduled refresh.

![Power BI Refresh Data](Images/PowerBIRefresh.png)

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

## Direct API Usage (No Database)

If you prefer to integrate directly (without deploying the sample database or console app), implement the following. Running the Quick Start once first is still helpful for understanding structure.

### Obtain an OAuth 2.0 Access Token

Flow: Client Credentials.

- Authority: `https://identity.work-wallet.com`
- Discovery: `https://identity.work-wallet.com/.well-known/openid-configuration`
- Token endpoint: `https://identity.work-wallet.com/connect/token`
- Scope: `ww_bi_extract`

Form-style body (conceptual):

```text
client_id={ApiAccessClientId}&client_secret={ApiAccessClientSecret}&grant_type=client_credentials&scope=ww_bi_extract
```

### Call the BI Extract Endpoint (Paging)

Template:

```http
GET https://bi.work-wallet.com/dataextract/{DataSet}?walletId={WalletId}&walletSecret={WalletSecret}&pageNumber=1&pageSize=500
Authorization: Bearer {access_token}
```

Supported dataset names: see [Supported Datasets](#supported-datasets).

Rules:

- Keep `pageSize` ≤ 500.
- Increment `pageNumber` until returned page `Count < PageSize`.

### Change Tracking

Store the `SynchronizationVersion` returned in the `Context` block per dataset. Next run add:

```text
&lastSynchronizationVersion={storedVersion}
```

First ever call: omit the parameter (or set `0`). If you later pass a version lower than `MinValidSynchronizationVersion` the API will reject it—perform a full reload for that dataset.

Key context fields:

| Field | Description |
| --- | --- |
| `SynchronizationVersion` | High-water mark to persist |
| `MinValidSynchronizationVersion` | Earliest acceptable version for incremental calls |
| `Count` | Rows in this page |
| `FullCount` | Total rows (first page) |
| `PageNumber` / `PageSize` | Echo of request |

### Example (Truncated JSON)

```json
{
  "Context": {
    "Version": 1,
    "Count": 13,
    "FullCount": 13,
    "PageNumber": 1,
    "PageSize": 500,
    "SynchronizationVersion": 10101,
    "MinValidSynchronizationVersion": 9000,
    "Error": "",
    "UTC": "2025-03-26T14:54:59.127"
  },
  "Wallets": [ { "WalletId": "...", "Wallet": "Example Wallet" } ],
  "Locations": [ { "LocationId": "...", "LocationTypeCode": 2, "LocationType": "Operations Site" } ]
}
```

### Unpacking the JSON

Options:

- Process directly into relational structures (ETL) much like the stored procedures in `SampleCode/WorkWallet.BI.ClientDatabaseDeploy/Scripts/StoredProcedures`.
- Land raw page payloads first (ELT) then transform later; star-schema scripts in `SampleCode/WorkWallet.BI.ClientDatabaseDeploy/Scripts/Schema` can guide modelling.

### Multi-Region Access

If your execution region differs from the Wallet’s hosting region add a header:

```http
DataRegion: GB
```

Discover region:

```http
GET https://bi.work-wallet.com/wallet?walletId={WalletId}&walletSecret={WalletSecret}
```

Response contains `dataRegion`.

Notes:

- Only send the `DataRegion` header when you are calling from a different geographic region than the wallet’s hosting region (cross-region optimisation).
- If you supply a `DataRegion` value that does not match the wallet’s actual region the API returns **HTTP 400** with a plain text body: `Incorrect data region` (no JSON payload). Remove or correct the header (use the wallet lookup call above to confirm the right value) and retry.

### Error Handling

Error surfaces come from two places:

1. HTTP status codes (e.g. 4xx/5xx)
2. The `Context.Error` field in a successful (HTTP 200) JSON body

Always check both. A normal page response has `"Error": ""` (empty string).

Common scenarios:

| Signal | Meaning | Action |
| --- | --- | --- |
| HTTP 401 / 403 | Auth failure / bad credentials / scope | Re‑request token, verify client & wallet secrets. |
| HTTP 400 with body `Incorrect data region` | `DataRegion` header value does not match wallet region | Query wallet endpoint to confirm `dataRegion`; correct or omit header then retry. |
| HTTP 5xx | Transient platform issue | Retry with jitter; escalate if persistent. |
| `Context.Error = "Invalid LastSynchronizationVersion"` | Supplied `lastSynchronizationVersion` below `MinValidSynchronizationVersion` | Perform dataset re‑ingest: remove tracking entry and reload. |
| Other non-empty `Context.Error` | Dataset-specific or validation issue | Log, alert, and decide whether to skip or halt the run. |

Example truncated error-bearing payload:

```json
{
  "Context": {
    "Version": 1,
    "Count": 0,
    "FullCount": 0,
    "PageNumber": 1,
    "PageSize": 500,
    "SynchronizationVersion": 12000,
    "MinValidSynchronizationVersion": 11850,
    "Error": "Invalid LastSynchronizationVersion",
    "UTC": "2025-09-09T09:15:12.345"
  }
}
```

Handling guidance:

- Treat `Invalid LastSynchronizationVersion` as a controlled recovery path—do not loop retries with same value.
- For unknown `Context.Error` values: log, then continue with other datasets if safe.
- Ensure logging distinguishes transport errors (no JSON) vs logical errors (JSON with `Context.Error`).

### When to Use the Quick Start Instead

Use the provided pipeline if you want:

- Rapid deployment with validated transformation logic.
- Pre-built Power BI semantic models.
- Lower engineering overhead for change tracking.

The choices are interoperable: you can switch paths later using the same credentials.
