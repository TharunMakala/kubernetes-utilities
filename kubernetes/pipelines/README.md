# Azure DevOps Pipelines — Kubernetes

YAML pipelines for building, testing, and deploying Kubernetes workloads.

## Pipeline Overview

| File | Trigger | Purpose |
|------|---------|---------|
| `build-and-push.yaml` | PR + merge to `main` | Build Docker image, push to ACR, run security scan |
| `helm-lint-validate.yaml` | PR (any `helm/` change) | `helm lint` + `kubeval` + OPA dry-run |
| `deploy-dev.yaml` | Auto on merge to `main` | ArgoCD sync to apps-dev |
| `deploy-staging.yaml` | Manual gate after dev soak | ArgoCD sync to apps-staging |
| `deploy-prod.yaml` | Manual approval required | ArgoCD sync to apps-prod |

## Variable Groups (Azure DevOps Library)

| Group | Contains |
|-------|---------|
| `aks-shared` | ACR name, AKS resource group, subscription ID |
| `aks-dev` | Dev cluster name, kubeconfig secret name |
| `aks-staging` | Staging cluster name, ArgoCD app name |
| `aks-prod` | Prod cluster name, ArgoCD app name, approver group |

## Pipeline Agents

All pipelines run on the `azure-pipelines-agent` self-hosted pool running inside AKS
(namespace: `azure-devops-agents`). This avoids NAT traversal and uses Workload Identity
for ACR/AKS authentication.
