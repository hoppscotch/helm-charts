# Hoppscotch Enterprise Charts (SHE)

> Official Helm Charts for Hoppscotch Enterprise Edition

## Introduction

This Helm chart bootstraps Hoppscotch Enterprise Edition deployment on a Kubernetes cluster using the Helm package manager. The Enterprise Edition includes advanced features for large-scale deployments, enhanced security, and enterprise support.

## Enterprise Features

- Enhanced scalability options
- Enterprise-grade support
- Advanced monitoring
- Access control and security features
- Priority support

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- Valid Enterprise License
- Ingress controller (recommended)

## URLs Configuration

Update the URLs for frontend, backend, and admin in the `values.yaml` file as follows:

```yaml
urls:
  frontend: "https://frontend.yourdomain.com"
  backend: "https://backend.yourdomain.com"
  admin: "https://admin.yourdomain.com"
```

## Configuration

The following table lists the configurable parameters of the Hoppscotch Enterprise chart and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `hoppscotch/hoppscotch-enterprise` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `ingress.enabled` | Enable ingress controller resource | `true` |
| `enterprise.license` | Enterprise license key | `""` |

To modify the default configuration, Update the `values.yaml` file and specify your values or install chart with your custom values file:

```yaml
replicaCount: 3
image:
  repository: hoppscotch/hoppscotch-enterprise
  tag: "latest"
enterprise:
  licenseKey: "your-license-key"
service:
  type: LoadBalancer
```

Then install the chart with your custom values:

```bash
helm install [RELEASE_NAME] ./charts/she -f values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `[RELEASE_NAME]` deployment:

```bash
helm uninstall [RELEASE_NAME]
```

## Enterprise Support

As an enterprise customer, you have access to:
- Priority issue resolution
- Custom feature requests
- Implementation assistance

Contact enterprise support through:
- Enterprise Support Portal
- Priority Email Support

## License Management

Enterprise license management includes:
- License renewal
- Capacity management
- Feature activation

## Security and Compliance

Enterprise security features include:
- Access control
- Audit logging
- Enhanced security controls

## License

This project is licensed under the Enterprise License Agreement. Please refer to your license terms for details.