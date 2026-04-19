# scripts/

PowerShell helpers for day-2 operations on AKS clusters managed by this repo.

| Script | Purpose |
| --- | --- |
| `Get-ArgoCDAppHealth.ps1` | Roll up Argo CD application sync/health status by AppProject; optional pipeline gate. |
| `Get-ClusterResourceUtilization.ps1` | Compare pod requests against live metrics-server usage to flag over- and under-provisioned workloads. |

## Requirements

- PowerShell 7.2+
- `kubectl` on PATH, context set to the target cluster
- `argocd` CLI (or an API token) for Argo CD reporting
- `metrics-server` installed in the cluster for the utilization script

## Typical uses

```powershell
# Gate a release pipeline on a healthy prod AppProject
./Get-ArgoCDAppHealth.ps1 -Project prod -FailOnDegraded

# Spot over-provisioned workloads before a right-sizing review
./Get-ClusterResourceUtilization.ps1 -Namespace platform -OutFile util.csv
```
