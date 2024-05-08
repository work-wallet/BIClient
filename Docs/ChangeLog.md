# Work Wallet BI Client - Change Log

## 4th May 2024

C# libraries upgraded to .NET 8.0 with improved logging.

Azure Function App migrated from in-process to isolated model.

* If migrating an existing function app, follow the instructions [here](https://learn.microsoft.com/en-us/azure/azure-functions/migrate-dotnet-to-isolated-model?tabs=net8#update-your-function-app-in-azure).

## 16th January 2024

Added in the **Assets** module.

This includes asset assignments and asset custom fields (properties). Actions associated with assets were already available.

Currently asset inspection histories and defect reports are not included.

## 25th October 2023

The client sample and client function now support processing the data for multiple wallets.

If upgrading from a version of `WorkWallet.BI.ClientSample` older than `3.0.0.0` then review the changes to the `appsettings.config` configuration file.

If using a version of the Azure function `WorkWallet.BI.ClientFunction` older than `3.0.0.0` then review the changes to the Azure function configuration.
