# Legacy Schema

If you have an existing installation that predates August 2023 then your database will have been created manually from scripts and will not include the table `dbo.SchemaVersions`.

The `SchemaVersions` table is used by the deployment tool to record which schema scripts have been run. As this is missing, it is necessary to run a SQL script to record the current state of your database. This must be done before running `WorkWallet.BI.ClientDatabaseDeploy.exe`.

The script may be downloaded and unzipped from here: [InitialiseSchemaVersions.zip](https://workwalletcdnorigin.blob.core.windows.net/bi-client/InitialiseSchemaVersions.zip)

If your database does not included the `mart.ReportedIssue` table, then remove the insert row `WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0004 - ReportedIssues.sql` before running the script.

If your database table `mart.Location` does not include the column `Department` then remove insert row `WorkWallet.BI.ClientDatabaseDeploy.Scripts.Schema.0002 - CommonPatch.sql` before running the script.

Please contact Work Wallet for assistance if unsure of the above.
