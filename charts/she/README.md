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

### Database Configuration

#### ClickHouse Configuration
```yaml
enterprise:
  config:
    clickhouse:
      allowAuditLogs: true
      allowWorkspaceActivityLogs: true
      # External ClickHouse configuration
      external: false
      host: "your-clickhouse-host"
      user: "your-clickhouse-user"
      password: "your-clickhouse-password"
      
      # Self-hosted ClickHouse configuration
      clickhouse:
        image: "clickhouse/clickhouse-server:latest"
        username: "default"
        password: "clickhouse-password"
        persistence:
          size: "10Gi"
```

#### Redis Configuration
```yaml
enterprise:
  config:
    horizontalScaling:
      enabled: true
    redis:
      # External Redis configuration
      external: false
      host: "your-redis-host"
      password: "your-redis-password"
      
      # Self-hosted Redis configuration
      redis:
        image: "redis:latest"
        password: "redis-password"
        persistence:
          size: "5Gi"
```

### Database Deployment Options

1. **Self-hosted Databases**
   - Set `external: false` for automatic deployment
   - Databases are deployed as StatefulSets with persistent storage
   - Configuration managed through values.yaml

2. **External Databases**
   - Set `external: true` and provide connection details
   - Manual database management required

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