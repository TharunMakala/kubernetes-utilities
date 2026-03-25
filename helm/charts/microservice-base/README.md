# microservice-base Helm Chart

Opinionated base chart for deploying REST and gRPC microservices on Azure AKS.

## Features

- Zero-downtime `RollingUpdate` deployment strategy
- HPA (CPU + memory) enabled by default
- Pod anti-affinity to spread replicas across nodes
- Read-only root filesystem + non-root user enforced
- Prometheus scrape annotations pre-configured
- ServiceAccount with optional Azure Workload Identity annotation

## Usage

```bash
helm upgrade --install <release-name> ./microservice-base \
  --namespace apps-dev \
  -f values-dev.yaml \
  --set image.tag=<sha>
```

## Values Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| `image.repository` | `myacr.azurecr.io/my-service` | Container image |
| `image.tag` | `""` | Image tag; defaults to `appVersion` |
| `replicaCount` | `2` | Static replica count (ignored when HPA enabled) |
| `autoscaling.enabled` | `true` | Enable HPA |
| `autoscaling.minReplicas` | `2` | HPA minimum |
| `autoscaling.maxReplicas` | `10` | HPA maximum |
| `resources.limits.cpu` | `500m` | CPU limit |
| `resources.limits.memory` | `512Mi` | Memory limit |
| `ingress.enabled` | `false` | Create Ingress resource |
| `configMap.enabled` | `false` | Mount ConfigMap as envFrom |
