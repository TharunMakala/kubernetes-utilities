<#
.SYNOPSIS
    Reports Argo CD application sync and health status grouped by AppProject.

.DESCRIPTION
    Calls the Argo CD REST API (or falls back to `argocd app list -o json`) and
    produces a compact per-project rollup: how many apps are Synced / OutOfSync
    and Healthy / Degraded / Missing / Progressing, plus a list of any app that
    isn't both Synced and Healthy.

    Exits non-zero when --FailOnDegraded is set and any app is not Healthy, so it
    drops cleanly into a pipeline gate.

.PARAMETER Server
    Argo CD server hostname (no scheme). Required when using the REST API path.

.PARAMETER AuthToken
    Argo CD API bearer token. When omitted the script falls back to the argocd
    CLI, which must already be logged in.

.PARAMETER Project
    Optional AppProject filter. When provided, only apps in that project are
    included.

.PARAMETER FailOnDegraded
    Exit with code 2 when any application is not in both Synced + Healthy state.

.EXAMPLE
    # Use the REST API with a token
    .\Get-ArgoCDAppHealth.ps1 -Server argocd.prod.example.com -AuthToken $env:ARGOCD_TOKEN

.EXAMPLE
    # Use the CLI and gate a pipeline on it
    argocd login argocd.prod.example.com --sso
    .\Get-ArgoCDAppHealth.ps1 -Project prod -FailOnDegraded
#>
[CmdletBinding()]
param (
    [string] $Server,
    [string] $AuthToken,
    [string] $Project,
    [switch] $FailOnDegraded
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Apps {
    if ($Server -and $AuthToken) {
        $uri = "https://$Server/api/v1/applications"
        $headers = @{ Authorization = "Bearer $AuthToken" }
        return (Invoke-RestMethod -Uri $uri -Headers $headers).items
    }

    if (-not (Get-Command argocd -ErrorAction SilentlyContinue)) {
        throw "argocd CLI not found and no -Server/-AuthToken provided."
    }
    return argocd app list -o json | ConvertFrom-Json
}

$apps = Get-Apps
if ($Project) {
    $apps = $apps | Where-Object { $_.spec.project -eq $Project }
}

if (-not $apps) {
    Write-Warning "No applications matched."
    return
}

$flat = $apps | ForEach-Object {
    [pscustomobject]@{
        name         = $_.metadata.name
        project      = $_.spec.project
        destination  = "$($_.spec.destination.server) / $($_.spec.destination.namespace)"
        syncStatus   = $_.status.sync.status
        healthStatus = $_.status.health.status
        revision     = $_.status.sync.revision?.Substring(0, [math]::Min(8, ($_.status.sync.revision ?? '').Length))
    }
}

# Rollup by project
$byProject = $flat | Group-Object project | ForEach-Object {
    $grp = $_.Group
    [pscustomobject]@{
        project      = $_.Name
        total        = $grp.Count
        synced       = ($grp | Where-Object syncStatus   -EQ 'Synced').Count
        outOfSync    = ($grp | Where-Object syncStatus   -EQ 'OutOfSync').Count
        healthy      = ($grp | Where-Object healthStatus -EQ 'Healthy').Count
        degraded     = ($grp | Where-Object healthStatus -EQ 'Degraded').Count
        progressing  = ($grp | Where-Object healthStatus -EQ 'Progressing').Count
        missing      = ($grp | Where-Object healthStatus -EQ 'Missing').Count
    }
}

Write-Host "Argo CD application rollup" -ForegroundColor Cyan
$byProject | Format-Table -AutoSize

$bad = $flat | Where-Object { $_.syncStatus -ne 'Synced' -or $_.healthStatus -ne 'Healthy' }
if ($bad) {
    Write-Host "`nApplications needing attention:" -ForegroundColor Yellow
    $bad | Format-Table name, project, syncStatus, healthStatus, destination -AutoSize
}

if ($FailOnDegraded -and $bad) {
    exit 2
}
