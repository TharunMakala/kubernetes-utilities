# kubernetes-utilities

Production-grade Kubernetes configuration for Azure Kubernetes Service (AKS).
Covers multi-environment deployments, GitOps with ArgoCD, Helm charts, security
hardening with OPA Gatekeeper, and Azure DevOps CI/CD pipelines.

## Repository Structure

```
.
└── kubernetes/
    ├── clusters/          # Per-environment Kustomize overlays (dev / staging / prod)
    ├── manifests/         # Cluster-wide manifests: RBAC, namespaces, network policies,
    │                      #   resource quotas, PDBs, HPA, VPA, ingress
    ├── helm/              # In-house Helm charts
    │   └── charts/
    │       ├── microservice-base/   # Base chart for all REST/gRPC microservices
    │       └── api-gateway/         # NGINX-based API gateway
    ├── gitops/            # ArgoCD projects and Application CRDs
    │   └── argocd/
    │       ├── install/             # ArgoCD Helm values
    │       ├── projects/            # AppProject per environment
    │       └── applications/        # App-of-apps per environment
    ├── security/          # OPA Gatekeeper constraints + Azure Workload Identity configs
    │   ├── gatekeeper/
    │   └── workload-identity/
    ├── scaling/           # KEDA ScaledObjects for event-driven autoscaling
    └── pipelines/         # Azure DevOps YAML pipeline definitions
```

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| `kubectl` | 1.28 |
| `helm` | 3.14 |
| `kustomize` | 5.3 |
| `argocd` CLI | 2.10 |
| Azure CLI | 2.57 |

## Quick Start

```bash
# Authenticate to AKS
az login
az aks get-credentials --resource-group rg-aks-prod --name aks-prod --overwrite-existing

# Apply cluster base (namespaces, RBAC, network policies, quotas)
kubectl apply -k kubernetes/clusters/prod/

# Lint Helm charts
helm lint kubernetes/helm/charts/microservice-base
helm lint kubernetes/helm/charts/api-gateway
```

## Environments

| Environment | AKS Tier | Node SKU | Min Nodes | Max Nodes |
|-------------|----------|----------|-----------|-----------|
| dev | Free | Standard_D2s_v3 | 1 | 3 |
| staging | Standard | Standard_D4s_v3 | 2 | 5 |
| prod | Standard | Standard_D8s_v3 | 3 | 20 |

## GitOps Flow

All production changes flow through ArgoCD. Direct `kubectl apply` in prod is blocked by OPA Gatekeeper.

1. Open a PR against `main`
2. Azure DevOps runs `helm lint` + `kubeval` + OPA policy checks
3. On merge, ArgoCD auto-syncs dev; staging and prod require approval gates
4. Sync status is posted back to the Azure DevOps PR

## Contact

Tharun Makala — mtarun523@gmail.com
