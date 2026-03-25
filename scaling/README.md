# Scaling

Autoscaling configurations for AKS workloads.

## Components

| Tool | Purpose |
|------|---------|
| **HPA** | CPU/memory-based horizontal scaling (built-in Kubernetes) |
| **VPA** | Right-size resource requests based on actual usage |
| **KEDA** | Event-driven scaling (Azure Service Bus, Event Hub, custom metrics) |

## KEDA Installation

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm upgrade --install keda kedacore/keda \
  --namespace keda \
  --create-namespace \
  --set podIdentity.azureWorkload.enabled=true
```

## Decision Guide

| Scenario | Recommended |
|----------|-------------|
| Scale on CPU/memory | HPA |
| Scale on queue depth (Azure Service Bus) | KEDA |
| Scale on Event Hub lag | KEDA |
| Right-size a batch job | VPA (Off mode) |
| Right-size a long-running service | VPA (Recommendation mode) |

> **Note:** Do not use HPA and VPA in Auto mode simultaneously on the same Deployment.
> Use KEDA + VPA Recommendation or HPA + VPA Off.
