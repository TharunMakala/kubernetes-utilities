# kubernetes-utilities

Production-grade Kubernetes configuration for Azure Kubernetes Service (AKS).
Covers multi-environment cluster management, GitOps with ArgoCD, in-house Helm charts,
security hardening with OPA Gatekeeper, event-driven autoscaling with KEDA,
and Azure DevOps CI/CD pipelines.

---

## Repository Structure

```
.
├── clusters/                        # Per-environment Kustomize overlays
│   ├── dev/
│   ├── staging/
│   └── prod/
│
├── manifests/                       # Cluster-wide Kubernetes manifests
│   ├── namespaces/
│   ├── rbac/
│   ├── network-policies/
│   ├── resource-quotas/
│   ├── pod-disruption-budgets/
│   ├── hpa/
│   ├── vpa/
│   └── ingress/
│
├── helm/                            # In-house Helm charts
│   └── charts/
│       ├── microservice-base/       # Base chart for REST/gRPC microservices
│       └── api-gateway/             # NGINX-based API gateway
│
├── gitops/                          # ArgoCD configuration
│   └── argocd/
│       ├── install/                 # ArgoCD Helm values
│       ├── projects/                # AppProject per environment
│       └── applications/            # App-of-apps (dev / staging / prod)
│
├── security/                        # Policy enforcement and identity
│   ├── gatekeeper/                  # OPA constraint templates and constraints
│   └── workload-identity/           # Azure Workload Identity configs
│
├── scaling/                         # Event-driven and right-sizing configs
│   └── keda/                        # KEDA ScaledObjects (Service Bus, Event Hub)
│
└── pipelines/                       # Azure DevOps YAML pipelines
```

---

## Environments

| Environment | AKS Tier | Node SKU | Min Nodes | Max Nodes |
|-------------|----------|----------|-----------|-----------|
| dev | Free | Standard_D2s_v3 | 1 | 3 |
| staging | Standard | Standard_D4s_v3 | 2 | 5 |
| prod | Standard | Standard_D8s_v3 | 3 | 20 |

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| `kubectl` | 1.28 |
| `helm` | 3.14 |
| `kustomize` | 5.3 |
| `argocd` CLI | 2.10 |
| Azure CLI | 2.57 |

---

## Quick Start

```bash
# Authenticate
az login
az aks get-credentials --resource-group rg-aks-prod --name aks-prod --overwrite-existing

# Apply cluster base (namespaces, RBAC, network policies, quotas)
kubectl apply -k clusters/prod/

# Lint Helm charts
helm lint helm/charts/microservice-base
helm lint helm/charts/api-gateway
```

---

## GitOps Flow

All production changes flow through ArgoCD. Direct `kubectl apply` in `apps-prod`
is blocked by OPA Gatekeeper policy.

1. Open a PR against `main`
2. Azure DevOps runs `helm lint` + `kubeval` + OPA conftest checks in the PR pipeline
3. On merge, ArgoCD auto-syncs dev; staging and prod require approval gates
4. Sync status is posted back to the Azure DevOps PR as a comment

---

## Contact

Tharun Makala — mtarun523@gmail.com
