# Kubernetes Manifests

Raw Kubernetes YAML applied via `kubectl` or Kustomize overlays.
Helm charts live under `../helm/` — this directory is for cluster-wide primitives.

## Structure

| Directory | Contents |
|-----------|----------|
| `namespaces/` | Namespace definitions for every environment + platform tools |
| `rbac/` | ClusterRoles, Roles, ClusterRoleBindings, RoleBindings |
| `network-policies/` | Default-deny + namespace-scoped allow rules |
| `resource-quotas/` | Per-namespace CPU / memory / object count limits |
| `pod-disruption-budgets/` | PDB specs for stateful and critical workloads |
| `hpa/` | HorizontalPodAutoscaler baseline configs |
| `vpa/` | VerticalPodAutoscaler recommendation configs |
| `ingress/` | Ingress-nginx and cert-manager Helm value overrides |

## Applying

```bash
# All namespaces
kubectl apply -f manifests/namespaces/

# RBAC
kubectl apply -f manifests/rbac/

# Network policies (apply per-namespace)
kubectl apply -f manifests/network-policies/ -n apps-prod
```
