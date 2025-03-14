# Helm Charts

In-house Helm charts maintained for internal microservices and platform components.

## Charts

| Chart | Description | Version |
|-------|-------------|---------|
| `microservice-base` | Opinionated base chart for all REST/gRPC microservices | 1.0.0 |
| `api-gateway` | NGINX-based API gateway with TLS termination | 1.0.0 |

## Usage

```bash
# Lint
helm lint helm/charts/microservice-base

# Dry-run against dev cluster
helm upgrade --install my-service helm/charts/microservice-base \
  --namespace apps-dev \
  -f helm/charts/microservice-base/values-dev.yaml \
  --dry-run

# Deploy to staging
helm upgrade --install my-service helm/charts/microservice-base \
  --namespace apps-staging \
  -f helm/charts/microservice-base/values-staging.yaml
```

## Versioning

Charts follow [Semantic Versioning](https://semver.org/).
Bump `version` in `Chart.yaml` for every change; bump `appVersion` only when the default image tag changes.
