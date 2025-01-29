# Hoppscotch Community Charts (SHC)

> Official Helm Charts for Hoppscotch Community Edition

## Introduction

This Helm chart bootstraps Hoppscotch Community Edition deployment on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- Ingress controller

## URLs Configuration

Update the URLs for mainHost, backendHost, adminHost and related urls in the `values.yaml`:

```yaml
  urls:
    base: "http://frontend.yourdomain.com"
    shortcode: "http://frontend.yourdomain.com"
    admin: "http://admin.yourdomain.com"
    backend:
      gql: "http://backend.yourdomain.com/graphql"
      ws: "ws://backend.yourdomain.com/graphql"
      api: "http://backend.yourdomain.com/v1"
    redirect: "http://frontend.yourdomain.com"
    whitelistedOrigins: "http://backend.yourdomain.com,http://frontend.yourdomain.com,http://admin.yourdomain.com"

  # Ingress Configuration
  ingress:
    enabled: true
    mainHost: frontend.yourdomain.com
    adminHost: admin.yourdomain.com
    backendHost: backend.yourdomain.com
```
when **subpath is enabled**. Only update the mainHost and related urls:
```yaml
  urls:
    base: "http://yourdomain.com"
    shortcode: "http://yourdomain.com"
    admin: "http://yourdomain.com/admin"
    backend:
      gql: "http://yourdomain.com/backend/graphql"
      ws: "ws://yourdomain.com/backend/graphql"
      api: "http://yourdomain.com/backend/v1"
    redirect: "http://yourdomain.com"
    whitelistedOrigins: "http://yourdomain.com/backend,http://yourdomain.com,http://yourdomain.com/admin"

  enableSubpathBasedAccess: true
  
  # Ingress Configuration
  ingress:
    enabled: true
    mainHost: "yourdomain.com"
    # Services will be available at:
    # - Main: yourdomain.com
    # - Backend: yourdomain.com/backend
    # - Admin: yourdomain.com/admin
```

## Configuration

The following table lists the configurable parameters of the Hoppscotch Community chart and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `hoppscotch/hoppscotch` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `ingress.enabled` | Enable ingress controller resource | `false` |

To modify the default configuration, Update the `values.yaml` file and specify your values or install chart with your custom values file:

```yaml
replicaCount: 2
image:
  repository: hoppscotch/hoppscotch
  tag: "latest"
service:
  type: LoadBalancer
```

Then install the chart with your custom values:

```bash
helm install [RELEASE_NAME] ./charts/shc -f values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `[RELEASE_NAME]` deployment:

```bash
helm uninstall [RELEASE_NAME]
```

## Support

Get help and connect with the community:

- [Discord](https://hoppscotch.io/discord)
- [Telegram](https://hoppscotch.io/telegram)

## Contributing

We love your input! Check out our [Contributing Guide](CONTRIBUTING.md) for guidelines on how to proceed.

## License

This project is licensed under the [MIT License](LICENSE).