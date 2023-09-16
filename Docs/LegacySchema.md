# Legacy Schema

If you have an existing installation that predates August 2023 then your database will have been created manually from scripts and will not include the table `dbo.SchemaVersions`.

The `SchemaVersions` table is used by the deployment tool to record which schema scripts have been run. As this is missing, it is necessary to run a SQL script to record the current state of your database. This must be done before running `WorkWallet.BI.ClientDatabaseDeploy.exe`.

The script may be found in here [DocsInitialiseSchemaVersions.sql](./InitialiseSchemaVersions.sql)
