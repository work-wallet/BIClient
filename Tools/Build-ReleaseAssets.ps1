<#
.SYNOPSIS
    Publishes ClientSample and ClientDatabaseDeploy as framework-dependent, win-x64
    binaries and zips them up for attaching to a GitHub release.

.DESCRIPTION
    Uses `dotnet publish -r win-x64 --self-contained false` (rather than a plain build)
    so only the win-x64 native runtime assets are included, avoiding the multi-platform
    `runtimes/` bloat pulled in by packages like Microsoft.Data.SqlClient and Azure.Identity.

.PARAMETER Version
    Version string to embed in the zip file names (e.g. "5.0.0"). Defaults to the
    AssemblyVersion read from WorkWallet.BI.ClientSample.csproj.

.PARAMETER OutputDir
    Directory to write the publish output and zips to. Defaults to "<repo root>\release".

.EXAMPLE
    ./Build-ReleaseAssets.ps1

.EXAMPLE
    ./Build-ReleaseAssets.ps1 -Version 5.0.0 -OutputDir C:\Temp\release
#>
[CmdletBinding()]
param(
    [string]$Version,
    [string]$OutputDir,
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64"
)

$ErrorActionPreference = "Stop"

# This script lives under Tools/, one level below the repo root.
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not $OutputDir) {
    $OutputDir = Join-Path $repoRoot "release"
}

$projects = @(
    @{ Name = "WorkWallet.BI.ClientSample"; Path = "SampleCode/WorkWallet.BI.ClientSample/WorkWallet.BI.ClientSample.csproj" }
    @{ Name = "WorkWallet.BI.ClientDatabaseDeploy"; Path = "SampleCode/WorkWallet.BI.ClientDatabaseDeploy/WorkWallet.BI.ClientDatabaseDeploy.csproj" }
)

function Get-ProjectVersion([string]$csprojPath) {
    $xml = [xml](Get-Content $csprojPath)
    $raw = $xml.Project.PropertyGroup.AssemblyVersion | Select-Object -First 1
    $parsed = [version]$raw
    return "$($parsed.Major).$($parsed.Minor).$($parsed.Build)"
}

if (-not $Version) {
    $Version = Get-ProjectVersion (Join-Path $repoRoot $projects[0].Path)
}

Write-Host "Building release assets for version $Version ($Runtime, $Configuration)" -ForegroundColor Cyan

if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null

foreach ($project in $projects) {
    $projectPath = Join-Path $repoRoot $project.Path
    $projectVersion = Get-ProjectVersion $projectPath

    if ($projectVersion -ne $Version) {
        Write-Warning "$($project.Name) has AssemblyVersion $projectVersion, which does not match $Version"
    }

    $publishDir = Join-Path $OutputDir "$($project.Name)-v$Version-$Runtime"

    Write-Host "Publishing $($project.Name)..." -ForegroundColor Cyan
    dotnet publish $projectPath `
        -c $Configuration `
        -r $Runtime `
        --self-contained false `
        -o $publishDir

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed for $($project.Name)"
    }

    $zipPath = Join-Path $OutputDir "$($project.Name)-v$Version-$Runtime.zip"
    Write-Host "Zipping $($project.Name) -> $zipPath" -ForegroundColor Cyan
    Compress-Archive -Path (Join-Path $publishDir "*") -DestinationPath $zipPath -Force

    Remove-Item $publishDir -Recurse -Force
}

Write-Host "Done. Release assets written to $OutputDir" -ForegroundColor Green
Get-ChildItem $OutputDir -Filter *.zip | ForEach-Object {
    "{0,-70} {1,8:N2} MB" -f $_.Name, ($_.Length / 1MB)
}
