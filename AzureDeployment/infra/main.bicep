targetScope = 'resourceGroup'

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(50)
@description('Name of the environment. Used as a prefix in resource names.')
param environmentName string

@minLength(1)
@description('Primary Azure region for all resources (e.g. westeurope).')
param location string

@minLength(1)
@description('Azure SQL Server hostname without .database.windows.net (e.g. my-sql-server).')
param sqlServerName string

@minLength(1)
@description('Azure SQL Database name.')
param sqlDatabaseName string

@minLength(1)
@description('Timer trigger schedule as a NCRONTAB expression (UTC). See README for scheduling guidance.')
param timerSchedule string

@minValue(1)
@maxValue(10)
@description('Number of agent wallets to configure. A WalletId and WalletSecret Key Vault secret is created for each. Set WALLET_COUNT in the azd environment; defaults to 1 if omitted.')
param walletCount int = 1

@description('Object ID of the principal (user or group) to grant Key Vault Secrets Officer access, enabling them to set secret values post-deployment. Run `az ad signed-in-user show --query id --output tsv` to obtain your own ID. Set KEY_VAULT_ADMIN_OBJECT_ID in the azd environment. Leave empty to skip this role assignment.')
param keyVaultAdminObjectId string = ''

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().id, location))
var tags = { 'azd-env-name': environmentName }

// Storage account names: 3-24 chars, lowercase alphanumeric only, no hyphens.
// Environment name is stripped of hyphens/underscores then combined with a uniqueness token, capped at 24 chars.
var strippedEnvName = toLower(replace(replace(environmentName, '-', ''), '_', ''))
var storageAccountName = take('${strippedEnvName}${resourceToken}', 24)

// Azure built-in role definition IDs
var storageBlobDataOwnerRoleId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var storageQueueDataContributorRoleId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var storageTableDataContributorRoleId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var keyVaultSecretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

// Key Vault name: stripped environment name (up to 10 chars) + '-kv-' + 6-char uniqueness token.
// Must be 3–24 chars, alphanumeric and hyphens, globally unique across all Azure tenants.
var keyVaultName = '${take(strippedEnvName, 10)}-kv-${take(resourceToken, 6)}'

// Wallet app settings — one Key Vault reference per wallet per setting, indexed from 0
// Two separate arrays are required because Bicep for-expressions cannot be nested inside flatten().
var walletIdSettings = [for i in range(0, walletCount): {
  name: 'FuncOptions__AgentWallets__${i}__WalletId'
  value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=AgentWallet${i}WalletId)'
}]
var walletSecretSettings = [for i in range(0, walletCount): {
  name: 'FuncOptions__AgentWallets__${i}__WalletSecret'
  value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=AgentWallet${i}WalletSecret)'
}]

// ---------------------------------------------------------------------------
// Storage Account
// Flex Consumption uses this for the deployment package and runtime state.
// The function app authenticates via its managed identity — no connection string needed.
// ---------------------------------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource deploymentPackageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'deploymentpackage'
  properties: {
    publicAccess: 'None'
  }
}

// ---------------------------------------------------------------------------
// Monitoring
// ---------------------------------------------------------------------------

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${environmentName}-logs-${take(resourceToken, 6)}'
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${environmentName}-insights-${take(resourceToken, 6)}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ---------------------------------------------------------------------------
// App Service Plan (Flex Consumption)
// ---------------------------------------------------------------------------

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${environmentName}-plan-${take(resourceToken, 6)}'
  location: location
  tags: tags
  kind: 'functionapp'
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  properties: {
    reserved: true    // required for Linux-based Flex Consumption
  }
}

// ---------------------------------------------------------------------------
// Key Vault
// Stores sensitive credentials. The function app resolves them at runtime via
// Key Vault references — secrets are never stored directly in application settings.
// Secrets must be set manually after deployment (see README). Bicep does not write
// secret values so that redeployments never overwrite credentials already in place.
// ---------------------------------------------------------------------------

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

// ---------------------------------------------------------------------------
// Function App
// ---------------------------------------------------------------------------

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: '${environmentName}-${take(resourceToken, 6)}'
  location: location
  // azd uses the 'azd-service-name' tag to match this resource to the 'function' service in azure.yaml
  tags: union(tags, { 'azd-service-name': 'function' })
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}deploymentpackage'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '10.0'
      }
    }
    siteConfig: {
      cors: {
        allowedOrigins: ['https://portal.azure.com']
      }
      minTlsVersion: '1.2'
      appSettings: concat(
        [
          { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: applicationInsights.properties.ConnectionString }
          // Managed identity storage — no connection string required
          { name: 'AzureWebJobsStorage__accountName', value: storageAccount.name }
          // Work Wallet BI settings
          { name: 'BITimerTriggerSchedule', value: timerSchedule }
          { name: 'FuncOptions__AgentApiUrl', value: 'https://bi.work-wallet.com' }
          { name: 'FuncOptions__AgentPageSize', value: '500' }
          { name: 'FuncOptions__ApiAccessAuthority', value: 'https://identity.work-wallet.com' }
          { name: 'FuncOptions__ApiAccessScope', value: 'ww_bi_extract' }
          // Secrets resolved from Key Vault at runtime — set real values in Key Vault after deployment
          { name: 'FuncOptions__ApiAccessClientId', value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=ApiAccessClientId)' }
          { name: 'FuncOptions__ApiAccessClientSecret', value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=ApiAccessClientSecret)' }
          { name: 'sqldb_connection', value: 'Server=${sqlServerName}${environment().suffixes.sqlServerHostname};Database=${sqlDatabaseName};Authentication=Active Directory Default;Encrypt=True;' }
        ],
        walletIdSettings,
        walletSecretSettings
      )
    }
  }
  dependsOn: [deploymentPackageContainer, keyVault]
}

// ---------------------------------------------------------------------------
// Storage role assignments for the function app's managed identity
// Required for Flex Consumption — replaces storage connection strings
// ---------------------------------------------------------------------------

resource storageBlobDataOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, storageBlobDataOwnerRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataOwnerRoleId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, storageQueueDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRoleId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageTableDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, storageTableDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageTableDataContributorRoleId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// ---------------------------------------------------------------------------
// Key Vault role assignments
// ---------------------------------------------------------------------------

// Key Vault Secrets User — allows the function app to read secrets at runtime
resource keyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, functionApp.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Key Vault Secrets Officer — optional; grants the deployer permission to set secret values post-deployment
resource keyVaultSecretsOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(keyVaultAdminObjectId)) {
  name: guid(keyVault.id, keyVaultAdminObjectId, keyVaultSecretsOfficerRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsOfficerRoleId)
    principalId: keyVaultAdminObjectId
    principalType: 'User'
  }
}

// ---------------------------------------------------------------------------
// Outputs — azd reads these to wire up services and report post-deploy info
// ---------------------------------------------------------------------------

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.properties.ConnectionString
output functionAppName string = functionApp.name
output functionAppPrincipalId string = functionApp.identity.principalId
output keyVaultName string = keyVault.name
