# Cluster Overlays (Kustomize)

Per-environment Kustomize overlays that compose the base manifests with environment-specific patches.

## Structure

```
clusters/
├── dev/        # Points at Free-tier AKS; relaxed resource quotas
├── staging/    # Standard-tier AKS; mirrors prod topology at smaller scale
└── prod/       # Standard-tier AKS; strict quotas, full HA
```

## Applying an overlay

```bash
# Preview
kubectl kustomize clusters/prod/

# Apply
kubectl apply -k clusters/prod/
```

## Adding a new resource to an overlay

1. Add or update the file in `manifests/`
2. Reference it in the appropriate `kustomization.yaml` under `resources:`
3. Add a patch in the overlay if environment-specific overrides are needed
