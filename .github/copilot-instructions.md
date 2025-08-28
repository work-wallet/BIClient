# Work Wallet BI Client - AI Coding Guide

## Architecture Overview

This is a **data extraction and warehousing solution** that pulls health & safety data from the Work Wallet API into a local SQL Server database with a star schema design. The solution supports multiple deployment models: console app and Azure Function.

### Core Components

- **ClientCore**: Shared interfaces and options (`IProcessorService`, `IDataStoreService`, `ProcessorServiceOptions`)
- **ClientServices**: HTTP client services with OAuth2 bearer token handling and SQL data store implementation
- **ClientSample**: Console application entry point with cancellation support (ESC key)
- **ClientFunction**: Azure Function timer trigger wrapper around the same processor
- **ClientDatabaseDeploy**: DbUp-based database schema deployment tool

## Data Flow Architecture

1. **OAuth2 Token Acquisition**: `BearerTokenHandler` manages tokens from `https://identity.work-wallet.com`
2. **API Pagination**: `ProcessorService` handles paged requests to `https://bi.work-wallet.com/dataextract/[dataset]`
3. **Change Tracking**: Uses `lastSynchronizationVersion` to pull only changed data since last sync
4. **Database Storage**: JSON payloads processed by SQL stored procedures in `mart` schema

### Supported Datasets
```csharp
// From DataSets.cs - maps API endpoints to change tracking log types
{ "ReportedIssues", "REPORTED_ISSUE_UPDATED" }
{ "Inductions", "INDUCTION_UPDATED" }
{ "Permits", "PERMIT_UPDATED" }
{ "Actions", "ACTION_UPDATED" }
{ "Assets", "ASSET_UPDATED" }
{ "SafetyCards", "SAFETY_CARD_UPDATED" }
{ "Audits", "AUDIT2_UPDATED" }  // Note: AUDIT2 not AUDIT, as AUDIT was used for the original SiteAudits implementation
{ "PPEStocks", "PPE_STOCK_UPDATED" }  // PPE has 3 separate modules
{ "PPEStockHistories", "PPE_STOCK_HISTORY_UPDATED" }
{ "PPEAssignments", "PPE_ASSIGNMENT_UPDATED" }
```

## Configuration Patterns

### Multi-Wallet Support
All services support processing multiple wallets via `AgentWallets[]` array in configuration.

### Environment-Specific Config
- **Console**: `appsettings.json` with user secrets in DEBUG
- **Azure Function**: `local.settings.json` for development, Azure App Settings for production (nested config like `FuncOptions:AgentWallets:[0]:WalletId`)
- **Database Deploy**: Simple `AppSettings` section for connection string only

## Database Schema Approach

### DbUp Deployment Strategy
Scripts run in specific order via `RunGroupOrder`:
1. **Clean**: Drop stored procedures (ScriptType.RunAlways)
2. **Schema**: Create tables/views (ScriptType.RunOnce)
3. **Types**: User-defined types (ScriptType.RunAlways)
4. **StoredProcedures**: Data processing logic (ScriptType.RunAlways)

## Development Workflows

### Local Development
```powershell
# Database setup
cd SampleCode/WorkWallet.BI.ClientDatabaseDeploy
dotnet run

# Run data sync
cd ../WorkWallet.BI.ClientSample  
dotnet run  # Press ESC to cancel gracefully
```

### Azure Function Development
- Uses `local.settings.json` for local config
- Timer trigger schedule: NCRONTAB format (`"0 30 21 * * *"`)
- Application Insights recommended for logging visibility

## Error Handling Patterns

### API Error Recovery
- `Invalid lastSynchronizationVersion`: Reset via change detection table
- Multi-region support: Add `DataRegion` header for cross-region calls
- Page size limit: Max 500 (performance/payload size balance)

### Logging Strategy
- `ILogger` throughout with structured logging
- `IProgressService` for console output in ClientSample
- Application Insights for Azure Function monitoring

## Power BI Integration

### File Structure
- `.pbip` projects (not `.pbix`) for source control
- `SemanticModel/` contains data model definitions
- `Report/` contains report layouts and visualizations
- Database connection configured via Power BI Options & Settings

### Data Refresh Pattern
Power BI connects directly to SQL Server database - no intermediate files or APIs required.

## Extension Points

- **Custom Progress Reporting**: Implement `IProgressService` 
- **Alternative Data Stores**: Implement `IDataStoreService`
- **Additional Datasets**: Add entries to `DataSets.cs` and corresponding stored procedures

## Critical Dependencies

- **.NET 8.0**: All projects target this runtime
- **Microsoft.Data.SqlClient**: Database connectivity
- **DbUp**: Database deployment and versioning
- **System.Text.Json**: API response processing
