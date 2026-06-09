# Work Wallet BI Client — Azure Deployment

> **Before proceeding**, read [section 5.7 (Azure Function Deployment)](../README.md#57-azure-function-deployment) in the main README. It covers the function app creation wizard, managed identity setup, database access grants, app settings reference, and local development configuration. This document covers only the `azd`-based infrastructure provisioning and is a companion to that section, not a replacement for it.

Deploys the `WorkWallet.BI.ClientFunction` Azure Function using the [Azure Developer CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview).

Running `azd up` provisions all required Azure infrastructure and deploys the function code in a single command — no manual portal steps required.

## Prerequisites

- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd) installed (`winget install Microsoft.Azd` on Windows)
- An Azure subscription with permission to create resources
- An existing Azure SQL Server and Database with the schema already deployed (see [database deployment](../README.md#55-database-deployment) in the main README)
- Microsoft Entra ID admin access to the target SQL database (required for the post-deploy SQL grants in step 4)
- Your Work Wallet API credentials (client ID, client secret, wallet ID, wallet secret)

## What Gets Provisioned

| Resource | Purpose |
| --- | --- |
| Storage Account | Runtime state and deployment package storage for Flex Consumption |
| Log Analytics Workspace | Backing store for Application Insights |
| Application Insights | Monitoring and structured logging |
| App Service Plan (Flex Consumption) | Serverless hosting plan |
| Function App (.NET 10 Isolated, Linux, 2048 MB) | Timer-triggered data extract |
| Key Vault | Stores sensitive credentials; function app resolves them at runtime via Key Vault references |

The function app is assigned a **system-assigned managed identity** automatically. Three storage role assignments are created so the function authenticates to storage without any connection string.

## Deployment Steps

### Step 1 — Authenticate and initialise

> **Important:** all `azd` commands must be run from the `AzureDeployment` folder. Run `cd AzureDeployment` before proceeding. If you run them from the repo root, azd will not find `azure.yaml` and will fail or create environment state in the wrong location.

```bash
cd AzureDeployment

azd auth login
azd env new <ENVIRONMENT_NAME>    # e.g. contoso-wwbi, northwind-wwbi, acme-corp-wwbi
```

> **Returning to an existing environment:** if the environment already exists (e.g. on a different machine or after re-cloning), use `azd env list` to see available environments and `azd env select` to activate one instead of creating a new one:
>
> ```bash
> azd env list # show all environments and which is currently active
> azd env select <ENVIRONMENT_NAME> # switch to an existing environment
> ```

The environment name is used directly as the prefix for all Azure resource names (e.g. `contoso-wwbi-lrhfnk` for the function app, `contosowwbilrhfnk` for the storage account). Choose a name that clearly identifies the client — this is especially useful when hosting multiple clients in a single Azure subscription.

**Environment name guidelines:**

- Use only lowercase letters, numbers, and hyphens
- Maximum **16 characters** recommended — storage account names are formed by stripping hyphens/underscores from the environment name and appending a uniqueness token, capped at 24 characters total; a shorter name ensures more of the uniqueness token remains visible and the name stays readable
- Examples: `contoso-wwbi`, `northwind-wwbi`, `acme-corp-wwbi`

> **First run only:** `azd up` may display a "check your Azure development tools" prompt listing optional tools (GitHub Copilot CLI, Bicep VS Code Extension, etc.). Neither is required for deployment. Press **Enter** to install the pre-selected items, or use **Space** to deselect them and then **Enter** to skip. This prompt does not appear on subsequent runs.

### Step 2 — Set required parameters

Set the Azure region and SQL connection details before running `azd up`:

```bash
azd env set AZURE_LOCATION westeurope # replace with your region — see common values below
azd env set AZURE_RESOURCE_GROUP <GROUP_NAME> # e.g. contoso-wwbi-app — see naming note below
azd env set AZURE_SQL_SERVER_NAME <SQL_SERVER_NAME> # hostname only, without .database.windows.net
azd env set AZURE_SQL_DATABASE_NAME <DATABASE_NAME>
azd env set TIMER_SCHEDULE '0 0 22 * * *' # NCRONTAB in UTC — see scheduling guidance below
azd env set WALLET_COUNT 1 # number of agent wallets; omit to default to 1

# Recommended: grants Key Vault Secrets Officer so you can set secrets after deployment.
# Use your own user object ID, or an Entra ID group object ID.

# PowerShell — individual user:
azd env set KEY_VAULT_ADMIN_OBJECT_ID (az ad signed-in-user show --query id --output tsv)

# PowerShell — Entra ID group (set both):
azd env set KEY_VAULT_ADMIN_OBJECT_ID (az ad group show --group "<GROUP_NAME>" --query id --output tsv)
azd env set KEY_VAULT_ADMIN_PRINCIPAL_TYPE Group

# bash/zsh — individual user:
# azd env set KEY_VAULT_ADMIN_OBJECT_ID $(az ad signed-in-user show --query id --output tsv)

# bash/zsh — Entra ID group (set both):
# azd env set KEY_VAULT_ADMIN_OBJECT_ID $(az ad group show --group "<GROUP_NAME>" --query id --output tsv)
# azd env set KEY_VAULT_ADMIN_PRINCIPAL_TYPE Group
```

> **Resource group naming:** use a dedicated group for this function app (e.g. `contoso-wwbi-app`). Keep the Azure SQL Server it in a separate group (e.g. `contoso-wwbi-db`) — this way `azd down` can tear down the function app infrastructure without touching the database.

Choose a timer schedule appropriate for your timezone. See [scheduling guidance](../README.md#561-scheduling-recommendations) for recommendations on avoiding peak times.

**Common Azure location values:**

| Region | Value |
| --- | --- |
| UK South | `uksouth` |
| UK West | `ukwest` |
| West Europe | `westeurope` |
| North Europe | `northeurope` |
| Australia East | `australiaeast` |
| Australia Southeast | `australiasoutheast` |
| East US | `eastus` |
| East US 2 | `eastus2` |
| West US | `westus` |
| Southeast Asia | `southeastasia` |

Use `az account list-locations --output table` to see the full list of available regions for your subscription.

### Step 3 — Provision infrastructure and deploy

```bash
azd up
```

azd will prompt for:

| Prompt | What to enter |
| --- | --- |
| Select an Azure Subscription | Choose your subscription |
| Pick a resource group | Select **Create a new resource group** — always use a dedicated resource group; `azd down` deletes the entire resource group regardless of whether it pre-existed, so sharing it with other resources is unsafe |

All other parameters (`environmentName`, `location`, `sqlServerName`, `sqlDatabaseName`) are supplied automatically from the azd environment — they will not be prompted.

Once answered, azd builds the function project from source, provisions all Azure resources, and deploys the function code. Takes approximately 5 minutes.

At the end of provisioning, `azd` prints the function app name and resource group — note these for the steps below.

> **Note:** on the very first deployment, azd may report a 503 "Site Unavailable" warning after the zip deploy step. This is harmless — the Flex Consumption app takes a few seconds to start, and azd's trigger-sync check can run before it is ready. The deployment itself succeeds.

### Step 4 — Grant database access (manual SQL step)

The function app authenticates to Azure SQL using its system-assigned managed identity. Grant access via a Microsoft Entra ID security group:

**Step 4a — Create an Entra ID security group and add the managed identity as a member.**

In the Azure portal, go to Microsoft Entra ID → Groups → New group. Create a security group (e.g. `WorkWallet_BI_Database_Access`). Then navigate to the function app → Settings → Identity and copy the Object (principal) ID. Add this as a member of the group.

**Step 4b — Grant the group permissions on the database.**

Connect to the target Azure SQL database as a Microsoft Entra ID admin and run:

```sql
-- Create a database user mapped to the Entra ID group
CREATE USER [WorkWallet_BI_Database_Access] FROM EXTERNAL PROVIDER;

-- Create a role that allows stored procedure execution
CREATE ROLE db_executor;
GRANT EXECUTE TO db_executor;

-- Grant the group membership of all required roles
ALTER ROLE db_datareader ADD MEMBER [WorkWallet_BI_Database_Access];
ALTER ROLE db_datawriter ADD MEMBER [WorkWallet_BI_Database_Access];
ALTER ROLE db_executor   ADD MEMBER [WorkWallet_BI_Database_Access];
```

Replace `WorkWallet_BI_Database_Access` with the name of your security group if you chose a different name.

### Step 5 — Set secret values in Key Vault

`azd up` provisions the Key Vault but does not write secret values, so that redeployments never overwrite credentials already in place. Set the four required secrets (and any additional wallet pairs) using the az CLI or the Azure portal (Key Vault → Objects → Secrets).

The Key Vault name is printed in the `azd up` deployment outputs, or retrieve it with:

```bash
# PowerShell
azd env get-values | Select-String keyVaultName
# bash/zsh
azd env get-values | grep keyVaultName
```

Then set the secret values:

```powershell
# PowerShell
az keyvault secret set --vault-name <KEY_VAULT_NAME> --name ApiAccessClientId --value "<API_ACCESS_CLIENT_ID>"
az keyvault secret set --vault-name <KEY_VAULT_NAME> --name ApiAccessClientSecret --% --value <API_ACCESS_CLIENT_SECRET>
az keyvault secret set --vault-name <KEY_VAULT_NAME> --name AgentWallet0WalletId --value "<WALLET_ID>"
az keyvault secret set --vault-name <KEY_VAULT_NAME> --name AgentWallet0WalletSecret --% --value <WALLET_SECRET>
```

For additional wallets, increment the index in the secret name (e.g. `AgentWallet1WalletId`, `AgentWallet1WalletSecret`, etc.).

> **Access note:** to run these commands your account needs **Key Vault Secrets Officer** on the Key Vault. If you set `KEY_VAULT_ADMIN_OBJECT_ID` before running `azd up`, this role was granted automatically. Otherwise, assign it in the Azure portal (Key Vault → Access control (IAM)) or via az CLI before running the commands above.
>
> **Special characters in secret values** (e.g. `$`): in bash/zsh wrap the value in single quotes — `'abc$def'`. In PowerShell, use the stop-parsing symbol `--%` immediately before `--value` — PowerShell passes everything after it verbatim to `az.cmd` without any variable expansion:
>
> ```powershell
> az keyvault secret set --vault-name <KEY_VAULT_NAME> --name <SECRET_NAME> --% --value abc$def
> ```
>
> If the value contains spaces, wrap it in double quotes after `--%`: `--% --value "abc $def"`. Note that PowerShell variables cannot be used after `--%`.

## Updating After Initial Deployment

To redeploy after a code or infrastructure change:

```bash
azd deploy     # redeploy function code only (no infrastructure changes)
# or
azd provision  # reprovision infrastructure only (no code deployment) — use when you have changed main.bicep or parameters but not the function code
# or
azd up         # reprovision infrastructure and redeploy code
```

## Tearing Down

To remove all provisioned Azure resources:

```bash
azd down
```

This deletes the **entire resource group** and all resources within it — including any resources not provisioned by azd if you reused an existing group. The SQL server, database, and Entra ID security group (created manually in step 4) are unaffected as they reside outside this resource group, but must be cleaned up separately if required.

> **Key Vault soft delete:** when a resource group is deleted, Azure places any Key Vaults inside it into a soft-deleted state — the vault is recoverable for 90 days but its name remains reserved. If you plan to redeploy with the same environment name in the same subscription, purge the soft-deleted vault first:
>
> ```bash
> az keyvault purge --name <KEY_VAULT_NAME> --location <LOCATION>
> ```
>
> Or use the Azure portal: **Key vaults** → **Manage deleted vaults** → select the vault → **Purge**.

## Further Reading

- [Main README](../README.md) — full configuration reference, error handling, and scheduling guidance
- [Azure Developer CLI documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Flex Consumption plan overview](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)
