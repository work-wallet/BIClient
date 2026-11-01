<#
.SYNOPSIS
    Publish Power BI sample projects (.SemanticModel / .Report folders) to a Power BI workspace, refresh models
    and run DAX queries - for interactive development and review of the samples.

.DESCRIPTION
    Dot-source this file, then call the functions. Uses the Azure CLI for tokens, so first sign in to the
    tenant that owns the workspace:  az login --tenant <tenant> --allow-no-subscriptions

    Uses the Fabric item definition REST APIs, which work in Pro workspaces as well as Fabric capacities.
    The model and report must already exist in the workspace (publish them once from Power BI Desktop and set
    the data source credentials in the service); these functions then overwrite their definitions in place.

    Never commit workspace, model or report IDs to the repo.

.EXAMPLE
    . .\Tools\PowerBI\PowerBIDev.ps1
    $ws = '<workspace-guid>'
    Get-PbiItems -WorkspaceId $ws
    Publish-PbiSemanticModel -WorkspaceId $ws -ModelId '<model-guid>' -Path .\PowerBISamples\X\X.SemanticModel
    Invoke-PbiRefresh -WorkspaceId $ws -ModelId '<model-guid>' -Wait
    Publish-PbiReport -WorkspaceId $ws -ReportId '<report-guid>' -ModelId '<model-guid>' -Path .\PowerBISamples\X\X.Report
    Invoke-PbiDax -WorkspaceId $ws -ModelId '<model-guid>' -Query 'EVALUATE ROW("n", COUNTROWS(Fact))'
#>

$script:FabricApi = 'https://api.fabric.microsoft.com/v1'
$script:PowerBIApi = 'https://api.powerbi.com/v1.0/myorg'

function Get-PbiToken([ValidateSet('Fabric', 'PowerBI')] [string]$Audience = 'Fabric') {
    $resource = if ($Audience -eq 'Fabric') { 'https://api.fabric.microsoft.com' } else { 'https://analysis.windows.net/powerbi/api' }
    $token = az account get-access-token --resource $resource --query accessToken -o tsv
    if (-not $token) { throw "No token. Run: az login --tenant <tenant> --allow-no-subscriptions" }
    @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
}

function Invoke-PbiLongRunning([string]$Method, [string]$Uri, $Body) {
    $headers = Get-PbiToken Fabric
    $json = if ($Body) { $Body | ConvertTo-Json -Depth 20 -Compress } else { $null }
    $response = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers -Body $json -UseBasicParsing
    if ($response.StatusCode -ne 202) {
        if ($response.Content) { return $response.Content | ConvertFrom-Json }
        return
    }
    $location = $response.Headers['Location'] | Select-Object -First 1
    do {
        Start-Sleep -Seconds 2
        $state = Invoke-RestMethod -Uri $location -Headers $headers
    } while ($state.status -notin 'Succeeded', 'Failed', 'Undefined')
    if ($state.status -ne 'Succeeded') { throw "Operation failed: $($state | ConvertTo-Json -Depth 10)" }
    try { Invoke-RestMethod -Uri "$location/result" -Headers $headers } catch { $state }
}

function Get-PbiItems([Parameter(Mandatory)] [string]$WorkspaceId) {
    (Invoke-RestMethod -Headers (Get-PbiToken Fabric) "$script:FabricApi/workspaces/$WorkspaceId/items").value |
        Select-Object id, type, displayName
}

function Get-PbiDefinitionParts([string]$Path, [string[]]$Exclude) {
    $root = (Resolve-Path $Path).Path
    Get-ChildItem $root -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
        if (-not ($Exclude | Where-Object { $relative -like $_ })) {
            @{ path = $relative; payload = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)); payloadType = 'InlineBase64' }
        }
    }
}

function Publish-PbiSemanticModel {
    <# Overwrites a published semantic model with a local .SemanticModel folder. Refresh afterwards if tables,
       columns or calculated tables changed. #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ModelId, [Parameter(Mandatory)] [string]$Path)
    $parts = @(Get-PbiDefinitionParts $Path @('.pbi/*', '.platform', 'diagramLayout.json'))
    Invoke-PbiLongRunning POST "$script:FabricApi/workspaces/$WorkspaceId/semanticModels/$ModelId/updateDefinition" @{ definition = @{ parts = $parts } } | Out-Null
    "Published semantic model ($($parts.Count) parts)"
}

function Publish-PbiReport {
    <# Overwrites a published report with a local .Report folder, binding it to the given published model
       (the local definition.pbir points at the model by relative path, which the service cannot use). #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ReportId,
          [Parameter(Mandatory)] [string]$ModelId, [Parameter(Mandatory)] [string]$Path)
    $headers = Get-PbiToken Fabric
    $workspace = Invoke-RestMethod -Headers $headers "$script:FabricApi/workspaces/$WorkspaceId"
    $model = Invoke-RestMethod -Headers $headers "$script:FabricApi/workspaces/$WorkspaceId/semanticModels/$ModelId"
    $connection = "Data Source=`"powerbi://api.powerbi.com/v1.0/myorg/$($workspace.displayName)`";initial catalog=$($model.displayName);integrated security=ClaimsToken;semanticmodelid=$ModelId"
    # The $schema line is required: without it the service treats byConnection as the legacy format.
    $pbir = [ordered]@{
        '$schema'        = 'https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json'
        version          = '4.0'
        datasetReference = @{ byConnection = @{ connectionString = $connection } }
    } | ConvertTo-Json -Depth 5
    $parts = @(Get-PbiDefinitionParts $Path @('.pbi/*', '.platform', 'definition.pbir'))
    $parts += @{ path = 'definition.pbir'; payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pbir)); payloadType = 'InlineBase64' }
    Invoke-PbiLongRunning POST "$script:FabricApi/workspaces/$WorkspaceId/reports/$ReportId/updateDefinition" @{ definition = @{ parts = $parts } } | Out-Null
    "Published report ($($parts.Count) parts)"
}

function Export-PbiDefinition {
    <# Downloads a published item's definition (e.g. to pick up edits made in the browser). Kind: reports | semanticModels #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [ValidateSet('reports', 'semanticModels')] [string]$Kind,
          [Parameter(Mandatory)] [string]$ItemId, [Parameter(Mandatory)] [string]$OutDir)
    $result = Invoke-PbiLongRunning POST "$script:FabricApi/workspaces/$WorkspaceId/$Kind/$ItemId/getDefinition" $null
    foreach ($part in $result.definition.parts) {
        $file = Join-Path $OutDir $part.path
        New-Item -ItemType Directory -Force -Path (Split-Path $file) | Out-Null
        [IO.File]::WriteAllBytes($file, [Convert]::FromBase64String($part.payload))
    }
    $result.definition.parts.path
}

function Invoke-PbiRefresh {
    <# Starts a refresh; with -Wait, polls until that refresh (matched by its request ID) finishes. #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ModelId, [switch]$Wait)
    $headers = Get-PbiToken PowerBI
    $uri = "$script:PowerBIApi/groups/$WorkspaceId/datasets/$ModelId/refreshes"
    $started = (Get-Date).ToUniversalTime().AddSeconds(-5)
    $response = Invoke-WebRequest -Method Post -Headers $headers -Uri $uri -Body '{"notifyOption":"NoNotification"}' -UseBasicParsing
    $requestId = $response.Headers['RequestId'] | Select-Object -First 1
    if (-not $Wait) { return "Refresh started ($requestId)" }
    do {
        Start-Sleep -Seconds 5
        $history = (Invoke-RestMethod -Headers $headers -Uri "$uri`?`$top=10").value
        # Match the refresh we started; fall back to start time if the service didn't return a request ID.
        $mine = if ($requestId) { $history | Where-Object requestId -eq $requestId | Select-Object -First 1 }
                else { $history | Where-Object { ([datetime]$_.startTime).ToUniversalTime() -ge $started } | Select-Object -First 1 }
    } while (-not $mine -or $mine.status -eq 'Unknown')
    "Refresh $($mine.status) $($mine.serviceExceptionJson)"
}

function Invoke-PbiDax {
    <# Runs a DAX query (EVALUATE ...) against a published model and returns the rows. Query errors (e.g. a
       measure with a syntax error) are thrown with just the service's message rather than returning nothing. #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ModelId, [Parameter(Mandatory)] [string]$Query)
    $body = @{ queries = @(@{ query = $Query }); serializerSettings = @{ includeNulls = $true } } | ConvertTo-Json -Depth 5
    try {
        $result = Invoke-RestMethod -Method Post -Headers (Get-PbiToken PowerBI) -Body $body `
            -Uri "$script:PowerBIApi/groups/$WorkspaceId/datasets/$ModelId/executeQueries"
    } catch {
        $detail = try { ($_.ErrorDetails.Message | ConvertFrom-Json).error.'pbi.error'.details[0].detail.value } catch { $null }
        throw "DAX query failed: $(if ($detail) { $detail } else { $_.Exception.Message })"
    }
    if ($result.results[0].error) { throw "DAX query failed: $($result.results[0].error.message)" }
    $result.results[0].tables[0].rows
}

function Test-PbiMeasures {
    <# Evaluates every measure defined in a local measures-table .tmdl against the published model and
       reports any that fail (e.g. a syntax error or a reserved word used as a variable name). #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ModelId, [Parameter(Mandatory)] [string]$TmdlPath)
    $table = (Select-String -Path $TmdlPath -Pattern '^table (.+)$' | Select-Object -First 1).Matches[0].Groups[1].Value.Trim("'")
    $names = Select-String -Path $TmdlPath -Pattern "^\tmeasure (.+?) =" | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim("'") }
    $failed = foreach ($name in $names) {
        try { Invoke-PbiDax -WorkspaceId $WorkspaceId -ModelId $ModelId -Query "EVALUATE ROW(""v"", '$table'[$name])" | Out-Null }
        catch { [pscustomobject]@{ Measure = $name; Error = $_.Exception.Message } }
    }
    if ($failed) { $failed } else { "All $($names.Count) measures in '$table' evaluate" }
}

function Get-PbiMeasureValues {
    <# Evaluates the measures in a local measures-table .tmdl in one filter context and lists their values, to
       sanity-check numbers and labels (e.g. the default 12-month period, an empty period or one record).
       -Filters: CALCULATETABLE filter arguments, e.g. "DATESBETWEEN ( 'Date'[Date], EDATE ( TODAY (), -12 ) + 1, TODAY () )".
       Mirror the report-level filters (e.g. "'Status'[Status] <> ""Deleted""") so values match the report.
       -Match: regex on measure names to include (colour and previous-period helpers are skipped). #>
    param([Parameter(Mandatory)] [string]$WorkspaceId, [Parameter(Mandatory)] [string]$ModelId, [Parameter(Mandatory)] [string]$TmdlPath,
          [string]$Filters = "", [string]$Match = ".")
    $table = (Select-String -Path $TmdlPath -Pattern '^table (.+)$' | Select-Object -First 1).Matches[0].Groups[1].Value.Trim("'")
    $names = Select-String -Path $TmdlPath -Pattern "^\tmeasure (.+?) =" | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim("'") } |
        Where-Object { $_ -match $Match -and $_ -notmatch 'Colour|PP$' }
    for ($i = 0; $i -lt $names.Count; $i += 25) {
        $chunk = $names[$i..([Math]::Min($i + 24, $names.Count - 1))]
        $cols = ($chunk | ForEach-Object { """$_"", '$table'[$_]" }) -join ', '
        $query = if ($Filters) { "EVALUATE CALCULATETABLE ( ROW ( $cols ), $Filters )" } else { "EVALUATE ROW ( $cols )" }
        $row = Invoke-PbiDax -WorkspaceId $WorkspaceId -ModelId $ModelId -Query $query
        $row.PSObject.Properties | ForEach-Object { [pscustomobject]@{ Measure = $_.Name.Trim('[]'); Value = $_.Value } }
    }
}
