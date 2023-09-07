# Work Wallet Business Intelligence (BI) Client

The [Work Wallet](https://www.work-wallet.com/) Health and Safety solution provides an API to allow organisations to automate the download of their Wallet data. The API is optimised for organisations requiring a regular feed of data for Business Intelligence (BI) purposes.

The datasets currently enabled for download are:

* Site Audits
* Reported Issues
* Inductions
* Permits
* Actions

The API uses a combination of paging and change tracking to efficiently transfer data from the Work Wallet cloud to your local environment.

This repository provides a quick start solution to enable an organisation to get up and running with the API without needing to write a line of code. The solution may be used as is, or may be modified to suit your specific requirements. *(Or you may use the solution as a reference and develop an API consumer using your preferred technology stack.)*

## Work Wallet BI Client Architecture

The sample solution comprises:

* Scripts to create a SQL Server database that receives the data from the API. The database has a [star schema](https://en.wikipedia.org/wiki/Star_schema) optimised as a data mart.
* A console application that calls the API and stores the returned data in the database. The application can be scheduled (using your preferred scheduler) to run on a periodic basis (e.g. daily) in order to fully automate the feed. *(The code is also available as an [Azure Function](https://azure.microsoft.com/en-gb/products/functions/).)*
* Sample [Power BI](https://powerbi.microsoft.com/) models and reports that import the data from the database and provide rich analytical capabilities. The reports are viewed using the free [Power BI Desktop](https://powerbi.microsoft.com/en-us/desktop/) application from Microsoft. These reports can be customised, data can be combined with other (non-Work Wallet) datasets etc.. Organisations with Power BI Pro licences can publish auto-updating reports to their intranet, and benefit from a full suite of collaborative features.

Power BI is not a prerequisite to use this solution - any BI tool may be used to read and process the data held within the data mart (database).

## Technology Stack

The sample solution provided here is based on the following technology:

* Database - Microsoft SQL Server *(Azure SQL, local instance, Express, etc.)*. Hardware resource requirements are minimal.
* Application Code - .NET 6.0 / C#
* BI Platform - Microsoft Power BI

The API itself is a standard RESTful API that runs over a secure HTTPS/TLS channel.

## Contained within this Repository

In the `SampleCode` folder is a [Visual Studio](https://visualstudio.microsoft.com/) solution file `WorkWallet.BI.Client.sln` - this may be used to open and build all the components.

Pre-built binaries are available for download. See [Binaries](#binaries) below.

The following projects are provided:

| Project | |
| --- | --- |
| `WorkWallet.BI.ClientDatabaseDeploy` | A console application that creates (and upgrades) the database. Creates the database schema plus the required types and stored procedures. |
| `WorkWallet.BI.ClientSample` | A console application that calls the API and populates the database with data. |
| `WorkWallet.BI.ClientFunction` | Same as for `WorkWallet.BI.ClientSample`, but packged as an Azure Function |

## Calling the API

API access is activated and secured on a per-Wallet basis.

Contact Work Wallet to request API access for your Wallet.

Once activated, you will be provided with the following settings:

* `ApiAccessClientId`
* `ApiAccessClientSecret`
* `AgentWalletId`
* `AgentWalletSecret`

These settings are required to call the API.

The API endpoint is at <https://bi.work-wallet.com> and the [OAuth 2.0](https://oauth.net/2/) authorisation server is at <https://identity.work-wallet.com>.

## Binaries

All binaries target [.NET 6.0](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)

| Tool | Download URL | Executable | Config. File |
| --- | --- | --- | --- |
| Database deployment | [WorkWallet.BI.ClientDatabaseDeploy_2.0.1.0.zip](https://base.azureedge.net/bi-client/WorkWallet.BI.ClientDatabaseDeploy_2.0.1.0.zip) | `WorkWallet.BI.ClientDatabaseDeploy.exe` | `appsettings.json` |
| Client sample | [WorkWallet.BI.ClientSample_2.0.1.0.zip](https://base.azureedge.net/bi-client/WorkWallet.BI.ClientSample_2.0.1.0.zip) | `WorkWallet.BI.ClientSample.exe` | `appsettings.json` |

## Creating or Upgrading the Database

`WorkWallet.BI.ClientDatabaseDeploy` project / executable

**If you have an existing installation that predates August 2023 then contact Work Wallet for an additional migration step.**

Edit `appsettings.json` and enter the required settings:

| Setting | | Description |
| --- | --- | --- |
| AppSettings | DatabaseConnectionString | database connection string |

Run `WorkWallet.BI.ClientDatabaseDeploy.exe` from a command prompt.

This will create the database if it does not exist.

(Warning: *all* stored procedures are dropped from the mart schema as a first step in the upgrade.)

## Calling the API to Download Data to the Database

`WorkWallet.BI.ClientSample` project / executable

Edit `appsettings.json` and enter the required settings:

| Setting | | Description |
| --- | --- | --- |
| ClientOptions | ApiAccessClientId | |
| | ApiAccessClientSecret | |
| | AgentWalletId | |
| | AgentWalletSecret | |
| ConnectionStrings | ClientDb | database connection string |

Run `WorkWallet.BI.ClientSample.exe` from a command prompt.

You can use your preferred task scheduler to automate the running of the executable.

## Configuring the Azure Function App

`WorkWallet.BI.ClientFunction` project

Ignore this section if not deploying as an Azure Function.

The following configuration settings are required:

| Setting | Example | Description |
| --- | --- | --- |
| BITimerTriggerSchedule | `0 30 21 * * *` | Cron expression |
| FuncOptions:AgentApiUrl | `https://bi.work-wallet.com` | |
| FuncOptions:AgentPageSize | `500` | |
| FuncOptions:AgentWalletId | | |
| FuncOptions:AgentWalletSecret | | |
| FuncOptions:ApiAccessAuthority | `https://identity.work-wallet.com` | |
| FuncOptions:ApiAccessClientId | | |
| FuncOptions:ApiAccessClientSecret | | |
| FuncOptions:ApiAccessScope | `ww_bi_extract` | |
| sqldb_connection | | database connection string |
