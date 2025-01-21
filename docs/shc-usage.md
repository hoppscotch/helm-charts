# Hoppscotch Charts - Community Edition (SHC) Usage Guide

This guide covers the installation and usage of the Community Edition of Hoppscotch Charts.

## Features

The Community Edition includes:
- Basic Kubernetes deployment configurations
- Community support

## Installation

### Digital Ocean Installation

1. **Prerequisites**
```bash
# Required tools
- Digital Ocean account with administrative access
- kubectl CLI tool
- Helm 3.x installed
```

2. **Deployment Steps**
```bash
# Configure access
export KUBECONFIG=path/to/k8s-config.yaml

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml

# Deploy application with default values
helm install [RELEASE_NAME] ./charts/shc

# Deploy application with custom values file
helm install [RELEASE_NAME] ./charts/shc -f [path-to-values-file]
```

### GCP Installation

1. **Prerequisites**
```bash
# Required tools
- Google Cloud account with GKE access
- gcloud CLI configured
- kubectl CLI tool
- Helm 3.x installed
```

2. **Deployment Steps**
```bash
# Configure cluster access
gcloud container clusters get-credentials cluster-name --zone zone --project project-id

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Deploy application with default values
helm install [RELEASE_NAME] ./charts/shc

# Deploy application with custom values file
helm install [RELEASE_NAME] ./charts/shc -f [path-to-values-file]
```

## Configuration

### Basic Configuration
```yaml
# Example values.yaml
replicaCount: 2
image:
  repository: hoppscotch/hoppscotch
  tag: "latest"
```

### Advanced Configuration
- Resource limits
- Persistence settings
- Service configurations
- Ingress settings

## Upgrading

To upgrade your deployment:
```bash
helm upgrade [RELEASE_NAME] ./charts/shc -f [path-to-values-file]
```

## Troubleshooting

Common issues and solutions:
1. Pod scheduling issues
2. Resource constraints
3. Network connectivity
4. Configuration errors

## Community Support

Get help from the community:
- GitHub Discussions
- Discord Channel
- Telegram Group