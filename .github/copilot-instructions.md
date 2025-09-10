# Work Wallet BI Client - Concise AI Guide

## 1. Core Architecture
Data extraction & load into SQL Server star schema. Two runtimes share the same processor:
- Console (`ClientSample`)
- Azure Function timer (`ClientFunction`)
Supporting projects: `ClientCore` (interfaces/options), `ClientServices` (HTTP + SQL store + auth), `ClientDatabaseDeploy` (DbUp deployer).

## 2. Data Flow Essentials
1. OAuth2 client credentials via `BearerTokenHandler` (identity endpoint).
2. Page API: `.../dataextract/{dataset}` (≤current API limit, currently 500; may be lower for some datasets).
3. Incremental sync using `lastSynchronizationVersion` (persist newest `SynchronizationVersion`).
4. Stored procs in `mart` schema parse JSON into tables.

Supported datasets (see `DataSets.cs` for mapping): Actions, Assets, Audits (AUDIT2), Inductions, Permits, PPEAssignments, PPEStockHistories, PPEStocks, ReportedIssues, SafetyCards.

## 3. Config & Deployment
- Multiple wallets: `AgentWallets[]` in config.
- Console: `appsettings.json` (user secrets in DEBUG for secrets).
- Function: `local.settings.json` locally; app settings in Azure (flattened keys like `FuncOptions:AgentWallets:0:WalletId`).
- Database deploy: run deployer (DbUp groups: Clean, Schema, Types, StoredProcedures).

Local run (summary): deploy DB → run console (ESC cancels). Function uses NCRONTAB schedule string.

## 4. Error Handling (Keep Table In README In Sync)
Evaluate HTTP status + `Context.Error`:
- 401/403: auth/scope → refresh/validate credentials.
- 400 "Incorrect data region": remove/fix `DataRegion` header after determining wallet region.
- 400 PageSize validation: automatically retry with smaller value using `maxPageSize` from response body.
- 429: rate limiting → retry with exponential backoff + jitter; respect `Retry-After` header.
- 5xx: retry with capped exponential backoff + jitter.
- `Invalid LastSynchronizationVersion`: delete tracking entry → full reload dataset.
- Other non-empty `Context.Error`: log and decide skip vs halt (no infinite retry).
Rules: empty `Context.Error` = success; respect current API limits (may vary per dataset).

## 5. Extension Points
- Progress output: implement `IProgressService`.
- Alternative storage: implement `IDataStoreService`.
- New dataset: add to `DataSets.cs`, create SQL processing proc(s), update docs & changelog.

## 6. Minimal Documentation Rules
- Single canonical guide: `README.md`.
- Embed sample config JSON inline in relevant sections (not a separate section).
- Keep README TOC explicitly numbered; leave other markdown to standard lint auto-numbering.
- Add rationale or clarifications under existing headings instead of creating new top-level ones unless substantial.

## 7. Changelog Updates
- Use `CHANGELOG.md` with Unreleased → versioned sections on release.
- Categories: Added / Changed / Fixed / Removed / Notes (only those needed).
- Note dataset additions with required DB deploy + optional full reload.
- Documentation-only changes go under Changed (Documentation) or Changed.

## 8. Release Checklist (Short Form)
1. DbUp scripts grouped correctly (RunOnce vs RunAlways validated).
2. Version bump applied if required.
3. README datasets & reset mapping updated.
4. Changelog: Unreleased moved to dated version.
5. Power BI samples updated if schema impact.
6. Error handling section reflects any new conditions.

## 9. Quick Reference: Do / Do Not
Do: keep error matrix current; embed config snippets; maintain dataset order; use structured tables for mappings.
Do Not: exceed current API limits (may vary per dataset); infinite-retry logical errors; introduce standalone sample config section; resurrect deleted docs.

## 10. Style Snapshot
Follow markdownlint defaults. Single H1 per file. Use fenced code blocks with language. README TOC explicitly numbered. Concise, present tense. Prefer inline code backticks. Keep tables lean.

## 11. Common Tasks
| Task | Action |
| --- | --- |
| Add dataset | Update `DataSets.cs`, SQL procs, README tables, changelog. |
| Schema change | Add/adjust DbUp script + procs; update Power BI model if needed. |

---
