# Hoppscotch Charts - Enterprise Edition (SHE) Usage Guide

This guide covers the installation and usage of the Enterprise Edition of Hoppscotch Charts.

## Enterprise Features

Additional features beyond the Community Edition:
- Enhanced scalability options
- High availability configurations
- Enterprise-grade support
- Advanced monitoring 

## Installation

### Digital Ocean Installation

1. **Prerequisites**
```bash
# Required tools
- Digital Ocean account with administrative access
- kubectl CLI tool
- Helm 3.x installed
- Valid enterprise license
```

2. **Deployment Steps**
```bash
# Configure access
export KUBECONFIG=path/to/k8s-config.yaml

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml

# Deploy application with default values
helm install [RELEASE_NAME] ./charts/she

# Deploy application with custom values file
helm install [RELEASE_NAME] ./charts/she -f [path-to-values-file]
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
helm install [RELEASE_NAME] ./charts/she

# Deploy application with custom values file
helm install [RELEASE_NAME] ./charts/she -f [path-to-values-file]
```

## Enterprise Configuration

### Basic Configuration
```yaml
# Example values.yaml
replicaCount: 2
image:
  repository: hoppscotch/hoppscotch-enterprise
  tag: "latest"
```

## Upgrading

To upgrade your deployment:
```bash
helm upgrade [RELEASE_NAME] ./charts/she -f [path-to-values-file]
```

## Compliance and Auditing

Enterprise features for compliance:
- Audit logging
- Compliance reporting
- Access control

## Enterprise Support

Contact enterprise support:
- Dedicated support portal
- Priority issue resolution
- Custom feature requests

## License Management
Managing your enterprise license:
- License renewal
- Adding capacity