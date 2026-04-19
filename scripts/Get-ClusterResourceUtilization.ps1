<#
.SYNOPSIS
    Flags over- and under-provisioned workloads by comparing requests/limits to
    actual usage from metrics-server.

.DESCRIPTION
    For every Pod in the target namespace (or cluster-wide), computes:
        - requested CPU/memory per container (spec.resources.requests)
        - actual CPU/memory usage (kubectl top pod --containers)
        - utilization ratio (usage / request)

    Then tags each container as:
        over-provisioned   utilization < 30% of request (wasted capacity)
        under-provisioned  utilization > 90% of request (throttling risk)
        ok                 otherwise
        no-request         requests not set (invisible to scheduler)

    Requires metrics-server in the cluster.

.PARAMETER Namespace
    Namespace to target. When omitted, runs cluster-wide.

.PARAMETER Context
    Optional kubectl context.

.PARAMETER OutFile
    Optional CSV path. When omitted, results are printed to the console.

.EXAMPLE
    .\Get-ClusterResourceUtilization.ps1 -Namespace platform -OutFile utilization.csv
#>
[CmdletBinding()]
param (
    [string] $Namespace,
    [string] $Context,
    [string] $OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ctxArg = if ($Context) { @('--context', $Context) } else { @() }
$nsArg  = if ($Namespace) { @('-n', $Namespace) } else { @('--all-namespaces') }

function ConvertFrom-CpuQuantity {
    param([string] $Value)
    if (-not $Value) { return 0 }
    if ($Value.EndsWith('n')) { return [double]$Value.TrimEnd('n') / 1e6 }  # nanocores -> millicores
    if ($Value.EndsWith('u')) { return [double]$Value.TrimEnd('u') / 1e3 }
    if ($Value.EndsWith('m')) { return [double]$Value.TrimEnd('m') }        # already millicores
    return [double]$Value * 1000                                            # cores -> millicores
}

function ConvertFrom-MemoryQuantity {
    param([string] $Value)
    if (-not $Value) { return 0 }
    switch -Regex ($Value) {
        '^(\d+)Ki$' { return [double]$matches[1] / 1024 }
        '^(\d+)Mi$' { return [double]$matches[1] }
        '^(\d+)Gi$' { return [double]$matches[1] * 1024 }
        '^(\d+)Ti$' { return [double]$matches[1] * 1024 * 1024 }
        '^(\d+)$'   { return [double]$matches[1] / (1024 * 1024) }
        default     { return 0 }
    }
}

Write-Host "Fetching pod specs..." -ForegroundColor Cyan
$podsJson = (& kubectl @ctxArg get pods @nsArg -o json) -join "`n" | ConvertFrom-Json

Write-Host "Fetching metrics (requires metrics-server)..." -ForegroundColor Cyan
$topRaw = & kubectl @ctxArg top pod @nsArg --containers --no-headers 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "kubectl top failed. Confirm metrics-server is installed and healthy."
}

# Parse: NAMESPACE POD CONTAINER CPU MEMORY  (or without NS if -n was given)
$usage = @{}
foreach ($line in $topRaw) {
    $cols = $line -split '\s+' | Where-Object { $_ }
    if ($Namespace) { $ns = $Namespace;  $pod = $cols[0]; $c = $cols[1]; $cpu = $cols[2]; $mem = $cols[3] }
    else            { $ns = $cols[0];   $pod = $cols[1]; $c = $cols[2]; $cpu = $cols[3]; $mem = $cols[4] }
    $usage["$ns/$pod/$c"] = [pscustomobject]@{
        cpuMilli = ConvertFrom-CpuQuantity $cpu
        memMi    = ConvertFrom-MemoryQuantity $mem
    }
}

$rows = foreach ($pod in $podsJson.items) {
    foreach ($c in $pod.spec.containers) {
        $key = "$($pod.metadata.namespace)/$($pod.metadata.name)/$($c.name)"
        $req = $c.resources.requests
        $reqCpu = if ($req -and $req.cpu)    { ConvertFrom-CpuQuantity $req.cpu    } else { 0 }
        $reqMem = if ($req -and $req.memory) { ConvertFrom-MemoryQuantity $req.memory } else { 0 }

        $u       = $usage[$key]
        $useCpu  = if ($u) { $u.cpuMilli } else { 0 }
        $useMem  = if ($u) { $u.memMi }    else { 0 }

        $cpuRatio = if ($reqCpu -gt 0) { [math]::Round($useCpu / $reqCpu, 2) } else { $null }
        $memRatio = if ($reqMem -gt 0) { [math]::Round($useMem / $reqMem, 2) } else { $null }

        $tag =
            if ($reqCpu -eq 0 -and $reqMem -eq 0) { 'no-request' }
            elseif (($cpuRatio -and $cpuRatio -gt 0.9) -or ($memRatio -and $memRatio -gt 0.9)) { 'under-provisioned' }
            elseif (($cpuRatio -and $cpuRatio -lt 0.3) -and ($memRatio -and $memRatio -lt 0.3)) { 'over-provisioned' }
            else { 'ok' }

        [pscustomobject]@{
            namespace  = $pod.metadata.namespace
            pod        = $pod.metadata.name
            container  = $c.name
            cpuReq_m   = $reqCpu
            cpuUse_m   = [math]::Round($useCpu, 0)
            cpuRatio   = $cpuRatio
            memReq_Mi  = $reqMem
            memUse_Mi  = [math]::Round($useMem, 0)
            memRatio   = $memRatio
            status     = $tag
        }
    }
}

$summary = $rows | Group-Object status | Select-Object Name, Count
Write-Host "`nSummary:" -ForegroundColor Cyan
$summary | Format-Table -AutoSize

if ($OutFile) {
    $rows | Export-Csv -NoTypeInformation -Path $OutFile -Encoding UTF8
    Write-Host "CSV: $OutFile" -ForegroundColor Green
} else {
    $rows | Sort-Object status, namespace, pod | Format-Table -AutoSize
}
