# GitOps — ArgoCD

All production workloads are managed via ArgoCD using the App-of-Apps pattern.
Manual `kubectl apply` in `apps-prod` is blocked by OPA Gatekeeper policy.

## Bootstrap ArgoCD

```bash
# Install ArgoCD (values tuned for AKS)
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  -f gitops/argocd/install/argocd-values.yaml

# Login
argocd login <argocd-host> --sso

# Apply projects
kubectl apply -f gitops/argocd/projects/

# Bootstrap app-of-apps
kubectl apply -f gitops/argocd/applications/
```

## Project Layout

| Project | Target namespace | Auto-sync |
|---------|-----------------|-----------|
| `dev` | apps-dev | Yes |
| `staging` | apps-staging | Yes (manual gate) |
| `prod` | apps-prod | No — requires approval |

## Sync Strategy

- **Dev**: Auto-sync with self-heal and prune enabled
- **Staging**: Auto-sync on merge to `main`; manual gate via Azure DevOps approval
- **Prod**: Manual sync triggered after staging soak period
