# Security

## OPA Gatekeeper

Policy-as-code enforced at admission time via OPA Gatekeeper.

| Constraint | Enforcement | Description |
|------------|-------------|-------------|
| `require-resource-limits` | deny | All containers must declare CPU + memory limits |
| `disallow-latest-tag` | deny | `:latest` image tag is not allowed in staging/prod |
| `require-non-root` | deny | Containers must run as non-root |
| `disallow-privilege-escalation` | deny | `allowPrivilegeEscalation: false` required |
| `require-read-only-rootfs` | warn | Read-only root filesystem recommended |

```bash
# Install Gatekeeper
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm upgrade --install gatekeeper gatekeeper/gatekeeper \
  --namespace gatekeeper-system \
  --set replicas=2

# Apply constraint templates
kubectl apply -f security/gatekeeper/constraint-templates/

# Apply constraints
kubectl apply -f security/gatekeeper/constraints/
```

## Azure Workload Identity

All pods needing Azure resource access use Workload Identity (federated credentials).
No client secrets or SP credentials are stored in Kubernetes Secrets.

See `workload-identity/` for per-service federated identity configurations.
