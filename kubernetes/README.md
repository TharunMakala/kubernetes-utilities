# Kubernetes Infrastructure — Azure AKS

Production-grade Kubernetes configuration for Azure Kubernetes Service (AKS), managed as code.
Covers multi-environment deployments (dev / staging / prod), GitOps with ArgoCD, Helm charts,
security hardening with OPA Gatekeeper, and Azure DevOps CI/CD pipelines.

---

## Repository Layout

```
kubernetes/
├── clusters/          # Per-environment AKS cluster overlays (Kustomize)
├── manifests/         # Cluster-wide Kubernetes manifests (RBAC, namespaces, policies)
├── helm/              # In-house Helm charts
├── gitops/            # ArgoCD projects and Application CRDs
├── security/          # OPA Gatekeeper constraints, Azure Workload Identity
├── scaling/           # KEDA ScaledObjects, HPA, VPA
└── pipelines/         # Azure DevOps YAML pipeline definitions
```

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

## Environment Overview

| Environment | AKS Tier | Node SKU | Min Nodes | Max Nodes |
|-------------|----------|----------|-----------|-----------|
| dev | Free | Standard_D2s_v3 | 1 | 3 |
| staging | Standard | Standard_D4s_v3 | 2 | 5 |
| prod | Standard | Standard_D8s_v3 | 3 | 20 |

---

## Quick Start

```bash
# Authenticate to AKS
az login
az aks get-credentials --resource-group rg-aks-prod --name aks-prod --overwrite-existing

# Apply namespace set for prod
kubectl apply -k clusters/prod/

# Lint all Helm charts
helm lint helm/charts/microservice-base
helm lint helm/charts/api-gateway
```

---

## GitOps Flow

All production changes flow through ArgoCD. Direct `kubectl apply` in prod is **not permitted**.

1. Open a PR against `main`
2. Azure DevOps runs `helm lint` + `kubeval` + OPA policy checks in the PR pipeline
3. On merge, ArgoCD detects the change and auto-syncs the affected Application
4. Sync status is reported back to the Azure DevOps PR comment

---

## Contact

Tharun Makala — mtarun523@gmail.com
