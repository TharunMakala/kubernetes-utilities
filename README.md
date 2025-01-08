# Azure Infrastructure — Terraform

Production-grade Terraform codebase for provisioning and managing Azure infrastructure. Built around a modular, environment-driven architecture with Azure DevOps CI/CD integration.

## Repository Structure

```
.
├── modules/              # Reusable Terraform modules
│   ├── networking/       # VNet, subnets, NSGs, peering
│   ├── compute/          # VMs, scale sets, availability sets
│   ├── aks/              # Azure Kubernetes Service cluster
│   ├── storage/          # Storage accounts, blob containers
│   └── monitoring/       # Log Analytics, alerts, dashboards
├── environments/         # Per-environment root modules
│   ├── dev/
│   ├── staging/
│   └── prod/
├── pipelines/            # Azure DevOps pipeline definitions
└── scripts/              # Helper shell scripts
```

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.5.0 |
| Azure CLI | >= 2.50.0 |
| Azure DevOps Agent | >= 3.x |

## Getting Started

### 1. Authenticate to Azure

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### 2. Bootstrap the backend

Each environment uses a dedicated Azure Storage Account for remote state. Initialise it before running Terraform:

```bash
./scripts/init-backend.sh <env>   # env = dev | staging | prod
```

### 3. Initialise Terraform

```bash
cd environments/dev
terraform init
```

### 4. Plan & Apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## Module Documentation

- [Networking](modules/networking/README.md)
- [Compute](modules/compute/README.md)
- [AKS](modules/aks/README.md)
- [Storage](modules/storage/README.md)
- [Monitoring](modules/monitoring/README.md)

## CI/CD

Pipelines are defined in `pipelines/`. Two pipeline files are provided:

| File | Purpose |
|------|---------|
| `terraform-plan.yml` | Runs `terraform plan` on every PR |
| `terraform-apply.yml` | Applies on merge to `main` (prod gated) |

## Contributing

1. Branch from `main` using `feat/`, `fix/`, or `chore/` prefixes.
2. Open a PR — the plan pipeline runs automatically.
3. At least one reviewer approval required before merge.

## License

Internal use only. All rights reserved.
