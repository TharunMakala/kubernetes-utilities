# api-gateway Helm Chart

NGINX-based API gateway deployed as a Kubernetes workload. Extends `microservice-base`
and adds gateway-specific concerns: rate limiting, JWT validation (optional), and NGINX config management.

## Features

- Wraps `microservice-base` chart via Helm dependency
- Configurable NGINX config via ConfigMap
- Optional JWT validation via NGINX auth_request
- Rate limiting annotations for ingress-nginx
- Prometheus metrics via nginx-prometheus-exporter sidecar

## Usage

```bash
# Build dependencies
helm dependency build helm/charts/api-gateway

# Deploy to staging
helm upgrade --install api-gateway helm/charts/api-gateway \
  --namespace apps-staging \
  --set gateway.image.tag=<sha>
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `gateway.replicaCount` | `2` | Base replica count |
| `gateway.ingress.enabled` | `true` | Create Ingress |
| `rateLimit.enabled` | `true` | Enable rate limiting |
| `rateLimit.requestsPerSecond` | `100` | RPS limit per IP |
| `jwtValidation.enabled` | `false` | Enable JWT auth |
