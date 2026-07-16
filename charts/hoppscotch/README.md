# Hoppscotch Helm Chart

![Version: 0.5.0](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square)
![AppVersion: 2026.6.1](https://img.shields.io/badge/AppVersion-2026.6.1-informational?style=flat-square)

Hoppscotch is a lightweight, web-based API development suite. It was built from the ground up with ease of use and
accessibility in mind providing all the functionality needed for developers with minimalist, unobtrusive UI.

## TL;DR

```bash
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts
helm install hoppscotch hoppscotch/hoppscotch
```

## Introduction

This chart bootstraps a [Hoppscotch](https://github.com/hoppscotch/hoppscotch) deployment on a
[Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- Persistent volume provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `hoppscotch`:

```bash
# Add the Hoppscotch Helm repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Install the Hoppscotch chart
helm install hoppscotch hoppscotch/hoppscotch \
--namespace hoppscotch \
--create-namespace \
--set aio.ingress.enabled=true \
--set aio.ingress.ingressClassName=nginx \
--set aio.ingress.hostname=hoppscotch.local \
--set postgresql.enabled=true \
--set postgresql.auth.username=hoppscotch \
--set postgresql.auth.password=hoppscotch \
--set postgresql.auth.database=hoppscotch
```

**Note**: Replace `nginx` and `hoppscotch.local` with the ingress controller class and hostname of your choice.

See [Configuration and Installation Details](#configuration-and-installation-details) and [Parameters](#parameters) for
more information on configuration options.

## Configuration and Installation Details

### Deployment Modes

Hoppscotch supports two deployment modes:

- **All-In-One** Using the All-In-One container which includes all services in a single container
- **Distributed** Using individual containers for each service

#### Using All-in-One Container

To deploy Hoppscotch using the AIO container, set the `deploymentMode` to `aio` in your values file:

```yaml
deploymentMode: aio
```

The AIO container supports two access modes:

- **Subpath Access**: Services are accessible via subpaths on a single port (80)
- **Multiport Access**: Each service is accessible on its own port

##### Subpath Access

When using AIO with subpath access, services can be accessed on port 80 from the following subpaths:

| Mode | Access  | Container | Service  | Ports | Path                |
| ---- | ------- | --------- | -------- | ----- | ------------------- |
| AIO  | Subpath | AIO       | Frontend | 80    | /                   |
| AIO  | Subpath | AIO       | Desktop  | 80    | /desktop-app-server |
| AIO  | Subpath | AIO       | Backend  | 80    | /backend            |
| AIO  | Subpath | AIO       | Admin    | 80    | /admin              |

To enable subpath access, set the following in your values file:

```yaml
deploymentMode: aio
hoppscotch:
  frontend:
    enableSubpathBasedAccess: true
```

##### Multiport Access

When using AIO with multiport access, services can be accessed on the following ports:

| Mode | Access    | Container | Service  | Ports | Path |
| ---- | --------- | --------- | -------- | ----- | ---- |
| AIO  | Multiport | AIO       | Frontend | 3000  | /    |
| AIO  | Multiport | AIO       | Desktop  | 3200  | /    |
| AIO  | Multiport | AIO       | Backend  | 3170  | /    |
| AIO  | Multiport | AIO       | Admin    | 3100  | /    |

To enable individual services, set the following in your values file:

```yaml
deploymentMode: aio
hoppscotch:
  frontend:
    enableSubpathBasedAccess: false
```

#### Using Individual Containers

To deploy Hoppscotch using individual containers for each service, set the `deploymentMode` to `distributed` in your
values file:

```yaml
deploymentMode: distributed
```

Services can be accessed on the following ports:

| Mode        | Access    | Container | Service  | Ports    | Path |
| ----------- | --------- | --------- | -------- | -------- | ---- |
| Distributed | Multiport | Frontend  | Frontend | 80, 3000 | /    |
| Distributed | Multiport | Frontend  | Desktop  | 3200     | /    |
| Distributed | Multiport | Backend   | Backend  | 80, 3170 | /    |
| Distributed | Multiport | Admin     | Admin    | 80, 3100 | /    |

Note: Only multiport access is supported in distributed mode.

### Enterprise Edition

Hoppscotch offers an Enterprise Edition with additional features and support. To enable Enterprise Edition, you must set
your enterprise license key and configure containers to use the enterprise images:

To set your enterprise license key, add the following to your values file:

```yaml
hoppscotch:
  backend:
    enterpriseLicenseKey: your-enterprise-license-key
```

To configure containers to use the enterprise images, set the following in your values file:

```yaml
aio:
  image:
    repository: hoppscotch/hoppscotch-enterprise
frontend:
  image:
    repository: hoppscotch/hoppscotch-enterprise-frontend
backend:
  image:
    repository: hoppscotch/hoppscotch-enterprise-backend
admin:
  image:
    repository: hoppscotch/hoppscotch-enterprise-admin
```

### Auto-Generating Config URLs

The chart automatically sets configuration URLs for the frontend, backend, and admin services based on the deployment
mode and ingress configuration.

```yaml
deploymentMode: aio
aio:
  ingress:
    enabled: true
    hostname: hoppscotch.example.com
    path: /
    tls: true
```

You can override these URLs by explicitly setting them in your values file.

```yaml
hoppscotch:
  frontend:
    adminUrl: https://hoppscotch.example.com/admin
    baseUrl: https://hoppscotch.example.com
    backendGqlUrl: https://hoppscotch.example.com/backend/graphql
    backendWsUrl: wss://hoppscotch.example.com/backend/graphql
    backendApiUrl: https://hoppscotch.example.com/backend/v1
    shortcodeBaseUrl: https://hoppscotch.example.com
  backend:
    auth:
      github:
        callbackUrl: https://hoppscotch.example.com/backend/v1/auth/github/callback
      google:
        callbackUrl: https://hoppscotch.example.com/backend/v1/auth/google/callback
      microsoft:
        callbackUrl: https://hoppscotch.example.com/backend/v1/auth/microsoft/callback
      oidc:
        callbackUrl: https://hoppscotch.example.com/backend/v1/auth/oidc/callback
      saml:
        callbackUrl: https://hoppscotch.example.com/backend/v1/auth/saml/callback
```

If deployment ingress is not enabled, then no URLs will be auto-generated.

```yaml
deploymentMode: aio
aio:
  ingress:
    enabled: false
```

See below the specific environment variables that are auto-generated.

#### AIO Auto-Generated Config URLs

##### AIO Frontend

| Key                     | Value                                                                 |
| ----------------------- | --------------------------------------------------------------------- |
| VITE_ADMIN_URL          | `https://${aio.ingress.hostname}/${aio.ingress.path}/admin`           |
| VITE_BACKEND_API_URL    | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1`      |
| VITE_BACKEND_GQL_URL    | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/graphql` |
| VITE_BACKEND_WS_URL     | `wss://${aio.ingress.hostname}/${aio.ingress.path}/backend/graphql`   |
| VITE_BASE_URL           | `https://${aio.ingress.hostname}/${aio.ingress.path}`                 |
| VITE_SHORTCODE_BASE_URL | `https://${aio.ingress.hostname}/${aio.ingress.path}`                 |

##### AIO Backend

<!-- markdownlint-disable MD013 MD034 -->

| Key                    | Value                                                                                    |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| GITHUB_CALLBACK_URL    | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1/auth/github/callback`    |
| GOOGLE_CALLBACK_URL    | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1/auth/google/callback`    |
| MICROSOFT_CALLBACK_URL | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1/auth/microsoft/callback` |
| OIDC_CALLBACK_URL      | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1/auth/oidc/callback`      |
| REDIRECT_URL           | `https://${aio.ingress.hostname}/${aio.ingress.path}`                                    |
| SAML_CALLBACK_URL      | `https://${aio.ingress.hostname}/${aio.ingress.path}/backend/v1/auth/saml/callback`      |
| WHITELISTED_ORIGINS    | `https://${aio.ingress.hostname},app://${aio.ingress.hostname}`                          |

<!-- markdownlint-enable MD013 MD034 -->

#### Distributed Auto-Generated Config URLs

##### Distributed Frontend

| Key                     | Value                                                                 |
| ----------------------- | --------------------------------------------------------------------- |
| VITE_ADMIN_URL          | `https://${admin.ingress.hostname}/${admin.ingress.path}`             |
| VITE_BACKEND_API_URL    | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1`      |
| VITE_BACKEND_GQL_URL    | `https://${backend.ingress.hostname}/${backend.ingress.path}/graphql` |
| VITE_BACKEND_WS_URL     | `wss://${backend.ingress.hostname}/${backend.ingress.path}/graphql`   |
| VITE_BASE_URL           | `https://${backend.ingress.hostname}/${backend.ingress.path}`         |
| VITE_SHORTCODE_BASE_URL | `https://${backend.ingress.hostname}/${backend.ingress.path}`         |

##### Distributed Backend

<!-- markdownlint-disable MD013 MD034 -->

| Key                    | Value                                                                                    |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| GITHUB_CALLBACK_URL    | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1/auth/github/callback`    |
| GOOGLE_CALLBACK_URL    | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1/auth/google/callback`    |
| MICROSOFT_CALLBACK_URL | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1/auth/microsoft/callback` |
| OIDC_CALLBACK_URL      | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1/auth/oidc/callback`      |
| REDIRECT_URL           | `https://${frontend.ingress.hostname}/${frontend.ingress.path}`                          |
| SAML_CALLBACK_URL      | `https://${backend.ingress.hostname}/${backend.ingress.path}/v1/auth/saml/callback`      |
| WHITELISTED_ORIGINS    | `https://${frontend.ingress.hostname},app://${frontend.ingress.hostname}`                |

<!-- markdownlint-enable MD013 MD034 -->

### Auto-Generating Secrets

The chart automatically generates secrets if not provided. These auto-generated secrets will be persisted and reused on
subsequent upgrades.

```yaml
hoppscotch:
  backend:
    auth:
      jwtSecret: "" # Random 64-character alphanumeric string used if not provided
      salt: "" # Random 64-character alphanumeric string used if not provided
      sessionSecret: "" # Random 64-character alphanumeric string used if not provided
      dataEncryptionKey: "" # Random 32-character alphanumeric string used if not provided
```

### Overriding Config Values

You can override config values using an existing secret, extra env vars, extra configmap, or extra secret. The order of
precedence of these methods is as follows (from highest to lowest):

1. Extra Env Vars
2. Extra Secret
3. Extra ConfigMap
4. Existing Secret

Extra env vars, secret, and configmap must be specified in container parameter sections (e.g. `aio`, `frontend`,
`backend`, `admin`)

Note: Config order of precedence is driven by Kubernetes. See
[Environment Variables in Kubernetes Pod](https://www.baeldung.com/ops/kubernetes-pod-environment-variables#1-order-of-precedence)
for more info.

### Using Extra Env Vars

To use extra environment variables:

```yaml
aio:
  extraEnvVars:
    - name: MY_ENV_VAR
      value: my-value
```

### Using Extra Secret

To use an extra secret:

```yaml
aio:
  extraEnvVarsSecret: my-extra-secret
```

### Using Extra ConfigMap

To use an extra configmap:

```yaml
aio:
  extraEnvVarsCM: my-extra-configmap
```

### Using Existing Secret

To use an existing secret:

```yaml
existingSecret: my-existing-secret
```

Note: The existing secret must contain all required keys. See
[templates/config/secret.yaml](templates/config/secret.yaml) for more info.

### Waiting for Database Readiness

Hoppscotch pods that connect to the database will wait for the database to be ready before starting. This is
accomplished by using the `wait-for-db` and `wait-for-migrations` default init containers.

The `wait-for-db` init container runs the following command to check if the database is ready:

```bash
# Wait for the database to be ready
until pg_isready -d ${DATABASE_URL}; do sleep 3; done
```

Once the database is ready, the `wait-for-migrations` init container runs the following command to ensure that database
migrations have been applied:

```bash
until ./node_modules/.bin/prisma migrate status; do sleep 2; done
```

This behavior can be disabled by setting the following in your values file:

```yaml
defaultInitContainers:
  waitForDatabase: false
  waitForMigrations: false
```

### Running Database Migrations

Database migrations are run automatically after installs and upgrades. The chart includes a migrations job that runs the
following command:

```bash
./node_modules/.bin/prisma migrate deploy
```

This behavior can be disabled by setting the following in your values file:

```yaml
migrations:
  enabled: false
```

Note the migrations job is not triggered by Helm hooks to avoid issues with the `--wait` flag. When the `--wait` flag is
set, Helm waits until all resources are ready before running `post-install` and `post-upgrade` hooks. This results in a
circular dependency because the migrations job waits for the Hoppscotch pods to be ready, but the Hoppscotch pods wait
for the migrations job to complete.

Instead the migration job is triggered by appending the release revision number to the job name to ensure that it is
unique for each release. This allows the job to be run multiple times without conflicts.

### Deploying on OpenShift

The chart is compatible with both vanilla Kubernetes and
[Red Hat OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift). On OpenShift, the `restricted-v2`
Security Context Constraint (SCC) assigns a random UID/GID and `fsGroup` from the namespace's allowed range and forbids
hardcoding them. To make the chart and its Bitnami dependencies (PostgreSQL, Redis, ClickHouse) compatible, set the
OpenShift compatibility mode:

```yaml
global:
  compatibility:
    openshift:
      # auto: adapt only when an OpenShift cluster is detected (default)
      # force: always adapt
      # disabled: never adapt
      adaptSecurityContext: auto
```

When adaptation is active, the chart removes `runAsUser`, `runAsGroup` and `fsGroup` from every `securityContext` so the
platform can assign the allowed IDs. The default `auto` value only adapts when an OpenShift cluster is detected (via the
`security.openshift.io/v1` API), so the same values file works unchanged on plain Kubernetes.

#### Installation walkthrough

These steps deploy Hoppscotch on a project that uses the default `restricted-v2` SCC. No cluster administrator or
elevated SCC required. Both `aio` and `distributed` modes are supported.

1. **Use OpenShift-compatible images.** `restricted-v2` runs the pod as a random non-root UID that cannot bind
   privileged ports (below `1024`) or write into a root-owned image filesystem. Hoppscotch images from app version
   `2026.6.1` onwards serve on an unprivileged port via the `HOPP_ALTERNATE_PORT` environment variable and keep their
   application directory group-writable, satisfying both requirements. Images older than `2026.6.1` may need a
   workaround; see [Container image requirements](#container-image-requirements).

2. **Enable OpenShift compatibility** so `runAsUser`, `runAsGroup` and `fsGroup` are dropped and the platform assigns
   IDs from the namespace range:

   ```yaml
   global:
     compatibility:
       openshift:
         adaptSecurityContext: auto
   ```

3. **Serve on unprivileged ports.** On `restricted-v2` a component cannot bind privileged port `80`.
   `HOPP_ALTERNATE_PORT` relocates a component's port-`80` listener to an unprivileged port **of your choice** (it is
   configurable, not a fixed value; `3080` is only an example). Set it **only** for images that would otherwise bind
   port `80`, and point that component's `containerPorts.http`, `service.ports.http` and `route.targetPort` at the same
   value. Images that already serve on an unprivileged port ignore it; see the distributed `frontend` below.

   All-in-one (subpath mode binds port `80`, so relocate it):

   ```yaml
   deploymentMode: aio
   aio:
     extraEnvVars:
       - name: HOPP_ALTERNATE_PORT
         value: "3080"
     containerPorts:
       http: 3080
     route:
       enabled: true
       targetPort: http
       tls:
         enabled: true
         termination: edge
         insecureEdgeTerminationPolicy: Redirect
   ```

   In distributed mode, the `frontend`, `backend` and `admin` images all bind port `80`, so relocate each of them with
   `HOPP_ALTERNATE_PORT`:

   ```yaml
   deploymentMode: distributed
   frontend:
     extraEnvVars:
       - name: HOPP_ALTERNATE_PORT
         value: "3080"
     containerPorts:
       http: 3080
     service:
       ports:
         http: 3080
     route:
       enabled: true
       targetPort: http
       tls:
         enabled: true
         termination: edge
         insecureEdgeTerminationPolicy: Redirect
   backend:
     extraEnvVars:
       - name: HOPP_ALTERNATE_PORT
         value: "3080"
     containerPorts:
       http: 3080
     service:
       ports:
         http: 3080
     route:
       enabled: true
       targetPort: http
       tls:
         enabled: true
         termination: edge
         insecureEdgeTerminationPolicy: Redirect
   admin:
     extraEnvVars:
       - name: HOPP_ALTERNATE_PORT
         value: "3080"
     containerPorts:
       http: 3080
     service:
       ports:
         http: 3080
     route:
       enabled: true
       targetPort: http
       tls:
         enabled: true
         termination: edge
         insecureEdgeTerminationPolicy: Redirect
   ```

4. **Set the public URLs.** Routes do not auto-populate the config URLs, so set them to the Route hostnames, which
   follow `<service-name>-<namespace>.<router-domain>`. Get the router domain with:

   ```bash
   oc whoami --show-console | sed 's#https://console-openshift-console\.##'
   ```

   In `aio` mode a single host serves the frontend (`/`), backend (`/backend`) and admin (`/admin`) via subpaths, so no
   extra URL configuration is needed.

   In `distributed` mode the frontend and admin are browser apps that call the backend directly, so you **must** set
   these URLs explicitly. Otherwise the UI loads but shows _"Failed to connect to the backend server"_. Point
   `hoppscotch.frontend.*` at the frontend/backend/admin Route hosts, and set the backend's `redirectUrl` and
   `whitelistedOrigins` (for CORS) to match (hosts follow `<service-name>-<namespace>.<router-domain>`):

   ```yaml
   hoppscotch:
     frontend:
       baseUrl: "https://hoppscotch-frontend-<namespace>.<router-domain>"
       shortcodeBaseUrl: "https://hoppscotch-frontend-<namespace>.<router-domain>"
       adminUrl: "https://hoppscotch-admin-<namespace>.<router-domain>"
       backendApiUrl: "https://hoppscotch-backend-<namespace>.<router-domain>/v1"
       backendGqlUrl: "https://hoppscotch-backend-<namespace>.<router-domain>/graphql"
       backendWsUrl: "wss://hoppscotch-backend-<namespace>.<router-domain>/graphql"
     backend:
       redirectUrl: "https://hoppscotch-frontend-<namespace>.<router-domain>"
       whitelistedOrigins:
         - "https://hoppscotch-frontend-<namespace>.<router-domain>"
         - "https://hoppscotch-admin-<namespace>.<router-domain>"
         - "https://hoppscotch-backend-<namespace>.<router-domain>"
   ```

   See [Auto-Generating Config URLs](#auto-generating-config-urls) for the full list of keys.

5. **Install:**

   ```bash
   helm upgrade --install hoppscotch hoppscotch/hoppscotch \
     --namespace hoppscotch --create-namespace \
     -f values.yaml
   ```

6. **Verify:**

   ```bash
   oc get pods -n hoppscotch     # migrations Completed; components Running
   oc get route -n hoppscotch    # one Route (aio) or three (distributed)
   ```

   Browse to the frontend Route to confirm the UI loads. The backend health endpoint is `/ping` (`/backend/ping` in
   `aio` subpath mode).

#### Exposing services with OpenShift Routes

In addition to standard `Ingress`, the chart can create native OpenShift
[Route](https://docs.openshift.com/container-platform/latest/networking/routes/route-configuration.html) resources.
Routes are an alternative to ingress and are disabled by default:

```yaml
deploymentMode: aio
aio:
  route:
    enabled: true
    host: "" # auto-assigned by OpenShift when empty
    targetPort: http
    tls:
      enabled: true
      termination: edge
      insecureEdgeTerminationPolicy: Redirect
```

In `distributed` mode, configure `frontend.route`, `backend.route` and `admin.route` instead.

Routes are only rendered on clusters that expose the `route.openshift.io/v1` API, so enabling them in a values file
shared with plain Kubernetes is a no-op there rather than a failed install. When previewing a Route offline with
`helm template`, pass `--api-versions route.openshift.io/v1` so it renders.

#### Port binding considerations

`restricted-v2` forbids binding privileged ports (below `1024`), so any component that would otherwise serve on port
`80` must be relocated to an unprivileged port with `HOPP_ALTERNATE_PORT`. Step 3 of the
[installation walkthrough](#installation-walkthrough) covers the per-component settings.

If an image cannot relocate its port, an alternative is AIO **multiport** mode, whose services listen on unprivileged
ports (`3000`, `3100`, `3170`, `3200`) directly:

```yaml
deploymentMode: aio
hoppscotch:
  frontend:
    enableSubpathBasedAccess: false
aio:
  route:
    enabled: true
    targetPort: http-frontend
```

#### Container image requirements

Under `restricted-v2` the container runs with a random non-root UID that does not own the image filesystem and cannot
bind privileged ports. Hoppscotch added non-root container support in **app version `2026.6.1`**, so images at
`2026.6.1` or newer keep their application directory group-writable and can serve on the port set by
`HOPP_ALTERNATE_PORT`. They run on `restricted-v2` without the `anyuid` SCC or a rebuilt image. **Use `2026.6.1` or
newer**, and still relocate the privileged port with `HOPP_ALTERNATE_PORT` as shown in step 3 of the
[installation walkthrough](#installation-walkthrough).

Images older than `2026.6.1` are not arbitrary-UID-safe: they write a `build.env` file into their application directory
(`/usr/src/app`) at startup and fail with `EACCES: permission denied, open 'build.env'`, and they still bind privileged
port `80`. To run such an image, grant the release ServiceAccount the `anyuid` SCC (requires a cluster administrator),
which runs the container as the image's own user so it can both write its files and bind port `80`:

```bash
oc adm policy add-scc-to-user anyuid -z <serviceAccountName> -n <namespace>
```

### Mock Server Wildcard Ingress

Hoppscotch's mock server is served by the backend under `/mock/<mock-id>/<path>` (and via
`/backend/mock/<mock-id>/<path>` when using AIO subpath access). The mock server wildcard ingress feature enables
subdomain-based access so that requests to `<mock-id>.mock.example.com/<path>` are transparently routed to the
appropriate backend path for your deployment mode.

The mock server ingress is **independent of the deployment mode**; it works with both `aio` and `distributed` modes. It
is disabled by default and has zero impact on existing deployments.

#### Enabling Mock Server Ingress

To enable the mock server wildcard ingress, set the following in your values file:

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: nginx # nginx | traefik | alb
    hostname: mock.example.com
    ingressClassName: nginx
```

This creates an Ingress resource with the wildcard host `*.mock.example.com` that routes all subdomain traffic to the
Hoppscotch backend service.

#### Supported Ingress Controllers

The `controllerType` toggle selects the ingress controller and configures the appropriate annotations automatically. An
unsupported value will cause the template to fail with a descriptive error message.

##### nginx

When `controllerType: nginx`, the chart adds nginx-specific annotations that (when snippet annotations are enabled on
your nginx ingress controller):

1. Extract the `mock-id` from the subdomain using a server-snippet regex capture group
2. Rewrite the request path to include the mock-id and the correct backend path prefix

> **Important**: The nginx option relies on `nginx.ingress.kubernetes.io/server-snippet` and
> `nginx.ingress.kubernetes.io/configuration-snippet` annotations. Many ingress-nginx deployments disable snippet
> annotations by default for security reasons (via `allow-snippet-annotations: "false"` in the controller config). You
> must enable snippet annotations on your ingress-nginx controller for the mock-id extraction to work. Without them, the
> rewrite will not function correctly.

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: nginx
    hostname: mock.example.com
    ingressClassName: nginx
```

This is the recommended controller type as it provides full subdomain-to-path rewriting including mock-id extraction
entirely at the ingress layer.

##### traefik

When `controllerType: traefik`, the chart creates an Ingress resource with a Traefik router middleware annotation and
also creates a `Middleware` CRD (`traefik.io/v1alpha1`) that rewrites the request path.

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: traefik
    hostname: mock.example.com
    ingressClassName: traefik
```

> **Note**: Traefik's `replacePathRegex` middleware can rewrite the request path but cannot extract the mock-id from the
> Host header (subdomain). When using Traefik, the backend application must resolve the mock-id from the `Host` header
> itself.

##### alb (AWS Load Balancer)

When `controllerType: alb`, the chart adds AWS ALB annotations for internet-facing load balancer configuration.

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: alb
    hostname: mock.example.com
```

> **Note**: AWS ALB does not support subdomain-to-path rewriting natively. When using ALB, the backend application must
> resolve the mock-id from the `Host` header itself.

#### Path Prefix Behavior

The path prefix used for URL rewriting depends on the deployment mode and subpath access setting:

| Deployment Mode | `enableSubpathBasedAccess` | Service Port | Path Prefix     |
| --------------- | -------------------------- | ------------ | --------------- |
| `aio`           | `true` (default)           | 80           | `/backend/mock` |
| `aio`           | `false`                    | 3170         | `/mock`         |
| `distributed`   | N/A                        | 80           | `/mock`         |

#### TLS Configuration

To enable TLS with a self-signed certificate:

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: nginx
    hostname: mock.example.com
    ingressClassName: nginx
    tls: true
    selfSigned: true
```

To use an existing TLS secret (e.g., from cert-manager):

```yaml
mockServer:
  ingress:
    enabled: true
    controllerType: nginx
    hostname: mock.example.com
    ingressClassName: nginx
    tls: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    tlsSecret: mock-example-com-wildcard-tls
```

The TLS secret covers the wildcard host `*.mock.example.com`.

## Parameters

<!-- markdownlint-disable MD013 MD034 -->

### Global Parameters

| Key                                                 | Type   | Default  | Description                                                                                                                                                                                                                                                                                                                                                         |
| --------------------------------------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| global.imageRegistry                                | string | `""`     | Global Docker image registry                                                                                                                                                                                                                                                                                                                                        |
| global.imagePullSecrets                             | list   | `[]`     | Global Docker registry secret names as an array                                                                                                                                                                                                                                                                                                                     |
| global.defaultStorageClass                          | string | `""`     | Global default storage class for persistent volumes                                                                                                                                                                                                                                                                                                                 |
| global.security.allowInsecureImages                 | bool   | `false`  | Allows skipping image verification                                                                                                                                                                                                                                                                                                                                  |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` | Adapt the securityContext sections of Hoppscotch and its dependencies to be compatible with OpenShift restricted-v2 SCC: removes `runAsUser`, `runAsGroup` and `fsGroup` so the platform assigns IDs from the namespace's allowed range. Possible values: `auto` (apply only if an OpenShift cluster is detected), `force` (always apply), `disabled` (never apply) |

### Common Parameters

| Key               | Type   | Default           | Description                                       |
| ----------------- | ------ | ----------------- | ------------------------------------------------- |
| nameOverride      | string | `""`              | String to override the chart name                 |
| fullnameOverride  | string | `""`              | String to override the fully qualified name       |
| namespaceOverride | string | `""`              | String to override the namespace                  |
| commonLabels      | object | `{}`              | Labels to add to all deployed objects             |
| commonAnnotations | object | `{}`              | Annotations to add to all deployed objects        |
| clusterDomain     | string | `"cluster.local"` | Kubernetes cluster domain name                    |
| extraDeploy       | list   | `[]`              | Array of extra objects to deploy with the release |

### Hoppscotch Common Parameters

| Key            | Type   | Default | Description                                                      |
| -------------- | ------ | ------- | ---------------------------------------------------------------- |
| deploymentMode | string | `"aio"` | Deployment mode for Hoppscotch (aio (all-in-one) or distributed) |
| existingSecret | string | `""`    | Name of existing secret containing Hoppscotch secrets            |

### Hoppscotch Application Parameters

| Key                                                       | Type   | Default                                | Description                                                                                                |
| --------------------------------------------------------- | ------ | -------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| hoppscotch.frontend.baseUrl                               | string | `""`                                   | Base URL where the Hoppscotch frontend will be accessible from                                             |
| hoppscotch.frontend.shortcodeBaseUrl                      | string | `""`                                   | URL used to generate shortcodes for sharing, can be the same as baseUrl                                    |
| hoppscotch.frontend.adminUrl                              | string | `""`                                   | URL where the Hoppscotch admin dashboard will be accessible from                                           |
| hoppscotch.frontend.backendGqlUrl                         | string | `""`                                   | URL for GraphQL endpoint within the Hoppscotch instance                                                    |
| hoppscotch.frontend.backendWsUrl                          | string | `""`                                   | URL for WebSocket endpoint within the Hoppscotch instance                                                  |
| hoppscotch.frontend.backendApiUrl                         | string | `""`                                   | URL for REST API endpoint within the Hoppscotch instance                                                   |
| hoppscotch.frontend.appTosLink                            | string | `""`                                   | Link to Terms of Service page (optional)                                                                   |
| hoppscotch.frontend.appPrivacyPolicyLink                  | string | `""`                                   | Link to Privacy Policy page (optional)                                                                     |
| hoppscotch.frontend.enableSubpathBasedAccess              | bool   | `true`                                 | Enable subpath based access (required for desktop app support)                                             |
| hoppscotch.frontend.localProxyServerEnabled               | bool   | `false`                                | Enable local proxy server for routing API requests (requires subpath access). Enterprise Edition required. |
| hoppscotch.frontend.proxyAppUrl                           | string | `""`                                   | URL of proxy server for routing API requests (optional). Enterprise Edition required.                      |
| hoppscotch.backend.aioAlternatePort                       | int    | `80`                                   | Alternate port for AIO container endpoint when using subpath access mode                                   |
| hoppscotch.backend.authToken.jwtSecret                    | string | `""`                                   | Secret key for JWT token generation and validation (auto-generated if empty)                               |
| hoppscotch.backend.authToken.tokenSaltComplexity          | int    | `10`                                   | Complexity of the SALT used for hashing (higher = more secure)                                             |
| hoppscotch.backend.authToken.magicLinkTokenValidity       | int    | `3`                                    | Duration of magic link token validity for sign-in (in days)                                                |
| hoppscotch.backend.authToken.refreshTokenValidity         | string | `"604800000"`                          | Validity of refresh token for authentication (in milliseconds)                                             |
| hoppscotch.backend.authToken.accessTokenValidity          | string | `"86400000"`                           | Validity of access token for authentication (in milliseconds)                                              |
| hoppscotch.backend.authToken.sessionSecret                | string | `""`                                   | Secret key for session management (auto-generated if empty)                                                |
| hoppscotch.backend.allowSecureCookies                     | bool   | `true`                                 | Allow secure cookies (recommended for HTTPS deployments)                                                   |
| hoppscotch.backend.dataEncryptionKey                      | string | `""`                                   | 32-character key for encrypting sensitive data stored in database (auto-generated if empty)                |
| hoppscotch.backend.redirectUrl                            | string | `""`                                   | Fallback URL for debugging when redirects fail                                                             |
| hoppscotch.backend.whitelistedOrigins                     | list   | `[]`                                   | List of origins allowed to interact with the app through cross-origin requests                             |
| hoppscotch.backend.auth.allowedProviders                  | list   | `["email"]`                            | List of allowed authentication providers (email, google, github, microsoft, oidc, saml)                    |
| hoppscotch.backend.auth.google.clientId                   | string | `""`                                   | Google OAuth client ID                                                                                     |
| hoppscotch.backend.auth.google.clientSecret               | string | `""`                                   | Google OAuth client secret                                                                                 |
| hoppscotch.backend.auth.google.callbackUrl                | string | `""`                                   | Google OAuth callback URL                                                                                  |
| hoppscotch.backend.auth.google.scope                      | list   | `["email","profile"]`                  | Google OAuth scopes to request                                                                             |
| hoppscotch.backend.auth.github.clientId                   | string | `""`                                   | GitHub OAuth client ID                                                                                     |
| hoppscotch.backend.auth.github.clientSecret               | string | `""`                                   | GitHub OAuth client secret                                                                                 |
| hoppscotch.backend.auth.github.callbackUrl                | string | `""`                                   | GitHub OAuth callback URL                                                                                  |
| hoppscotch.backend.auth.github.scope                      | list   | `["user:email"]`                       | GitHub OAuth scopes to request                                                                             |
| hoppscotch.backend.auth.githubEnterprise.enabled          | bool   | `false`                                | Enable GitHub Enterprise authentication. Enterprise Edition required.                                      |
| hoppscotch.backend.auth.githubEnterprise.authorizationUrl | string | `""`                                   | GitHub Enterprise authorization URL                                                                        |
| hoppscotch.backend.auth.githubEnterprise.tokenUrl         | string | `""`                                   | GitHub Enterprise token URL                                                                                |
| hoppscotch.backend.auth.githubEnterprise.userProfileUrl   | string | `""`                                   | GitHub Enterprise user profile URL                                                                         |
| hoppscotch.backend.auth.githubEnterprise.userEmailUrl     | string | `""`                                   | GitHub Enterprise user email URL                                                                           |
| hoppscotch.backend.auth.microsoft.clientId                | string | `""`                                   | Microsoft OAuth client ID                                                                                  |
| hoppscotch.backend.auth.microsoft.clientSecret            | string | `""`                                   | Microsoft OAuth client secret                                                                              |
| hoppscotch.backend.auth.microsoft.callbackUrl             | string | `""`                                   | Microsoft OAuth callback URL                                                                               |
| hoppscotch.backend.auth.microsoft.scope                   | string | `"user.read"`                          | Microsoft OAuth scopes to request                                                                          |
| hoppscotch.backend.auth.microsoft.tenant                  | string | `""`                                   | Microsoft OAuth tenant ID (common for multi-tenant apps)                                                   |
| hoppscotch.backend.auth.oidc.providerName                 | string | `""`                                   | OIDC provider display name                                                                                 |
| hoppscotch.backend.auth.oidc.issuer                       | string | `""`                                   | OIDC issuer URL                                                                                            |
| hoppscotch.backend.auth.oidc.authorizationUrl             | string | `""`                                   | OIDC authorization URL                                                                                     |
| hoppscotch.backend.auth.oidc.tokenUrl                     | string | `""`                                   | OIDC token URL                                                                                             |
| hoppscotch.backend.auth.oidc.userInfoUrl                  | string | `""`                                   | OIDC user info URL                                                                                         |
| hoppscotch.backend.auth.oidc.clientId                     | string | `""`                                   | OIDC client ID                                                                                             |
| hoppscotch.backend.auth.oidc.clientSecret                 | string | `""`                                   | OIDC client secret                                                                                         |
| hoppscotch.backend.auth.oidc.callbackUrl                  | string | `""`                                   | OIDC callback URL                                                                                          |
| hoppscotch.backend.auth.oidc.scope                        | list   | `["openid","profile","email"]`         | OIDC scopes to request                                                                                     |
| hoppscotch.backend.auth.saml.issuer                       | string | `""`                                   | SAML issuer identifier. Enterprise Edition required.                                                       |
| hoppscotch.backend.auth.saml.audience                     | string | `""`                                   | SAML audience identifier                                                                                   |
| hoppscotch.backend.auth.saml.callbackUrl                  | string | `""`                                   | SAML callback URL                                                                                          |
| hoppscotch.backend.auth.saml.cert                         | string | `""`                                   | SAML certificate for signature verification                                                                |
| hoppscotch.backend.auth.saml.entryPoint                   | string | `""`                                   | SAML identity provider entry point URL                                                                     |
| hoppscotch.backend.auth.saml.wantAssertionsSigned         | bool   | `true`                                 | Require signed SAML assertions                                                                             |
| hoppscotch.backend.auth.saml.wantResponseSigned           | bool   | `false`                                | Require signed SAML responses                                                                              |
| hoppscotch.backend.mailer.smtpEnabled                     | bool   | `true`                                 | Enable SMTP mailer for email delivery                                                                      |
| hoppscotch.backend.mailer.useCustomConfigs                | bool   | `false`                                | Use custom SMTP configuration instead of SMTP URL                                                          |
| hoppscotch.backend.mailer.addressFrom                     | string | `"no-reply@example.com"`               | Email address to use as sender                                                                             |
| hoppscotch.backend.mailer.smtpUrl                         | string | `"smtps://user:pass@smtp.example.com"` | SMTP URL for email delivery (used when useCustomConfigs is false)                                          |
| hoppscotch.backend.mailer.smtpHost                        | string | `""`                                   | SMTP host (used when useCustomConfigs is true)                                                             |
| hoppscotch.backend.mailer.smtpPort                        | int    | `587`                                  | SMTP port (used when useCustomConfigs is true)                                                             |
| hoppscotch.backend.mailer.smtpSecure                      | bool   | `true`                                 | Use secure connection for SMTP (used when useCustomConfigs is true)                                        |
| hoppscotch.backend.mailer.smtpUser                        | string | `""`                                   | SMTP username (used when useCustomConfigs is true)                                                         |
| hoppscotch.backend.mailer.smtpPassword                    | string | `""`                                   | SMTP password (used when useCustomConfigs is true)                                                         |
| hoppscotch.backend.mailer.tlsRejectUnauthorized           | bool   | `true`                                 | Reject unauthorized TLS connections                                                                        |
| hoppscotch.backend.rateLimit.ttl                          | int    | `60`                                   | Time window for rate limiting (in seconds)                                                                 |
| hoppscotch.backend.rateLimit.max                          | int    | `100`                                  | Maximum number of requests per IP within TTL window                                                        |
| hoppscotch.backend.enterpriseLicenseKey                   | string | `""`                                   | Enterprise license key for Hoppscotch Enterprise features                                                  |
| hoppscotch.backend.allowAuditLogs                         | bool   | `false`                                | Enable audit logs collection to ClickHouse. Enterprise Edition required.                                   |
| hoppscotch.backend.horizontalScalingEnabled               | bool   | `false`                                | Enable horizontal scaling with Redis for state management. Enterprise Edition required.                    |

### Hoppscotch AIO Container Parameters

| Key                                               | Type   | Default                    | Description                                                                                                                 |
| ------------------------------------------------- | ------ | -------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| aio.image.repository                              | string | `"hoppscotch/hoppscotch"`  | Hoppscotch image repository                                                                                                 |
| aio.image.pullPolicy                              | string | `"IfNotPresent"`           | Hoppscotch image pull policy                                                                                                |
| aio.image.tag                                     | string | `""`                       | Hoppscotch image tag                                                                                                        |
| aio.replicaCount                                  | int    | `1`                        | Number of Hoppscotch replicas                                                                                               |
| aio.containerPorts.http                           | int    | `80`                       | Hoppscotch HTTP container port                                                                                              |
| aio.containerPorts.https                          | int    | `443`                      | Hoppscotch HTTPS container port                                                                                             |
| aio.containerPorts.frontend                       | int    | `3000`                     | Hoppscotch frontend container port (for multiport access mode)                                                              |
| aio.containerPorts.desktop                        | int    | `3200`                     | Hoppscotch desktop container port (for multiport access mode)                                                               |
| aio.containerPorts.backend                        | int    | `3170`                     | Hoppscotch backend container port (for multiport access mode)                                                               |
| aio.containerPorts.admin                          | int    | `3100`                     | Hoppscotch admin container port (for multiport access mode)                                                                 |
| aio.readinessProbe.enabled                        | bool   | `true`                     | Enable readiness probe                                                                                                      |
| aio.readinessProbe.initialDelaySeconds            | int    | `0`                        | Initial delay seconds for readiness probe                                                                                   |
| aio.readinessProbe.periodSeconds                  | int    | `10`                       | Period seconds for readiness probe                                                                                          |
| aio.readinessProbe.timeoutSeconds                 | int    | `1`                        | Timeout seconds for readiness probe                                                                                         |
| aio.readinessProbe.failureThreshold               | int    | `3`                        | Failure threshold for readiness probe                                                                                       |
| aio.readinessProbe.successThreshold               | int    | `1`                        | Success threshold for readiness probe                                                                                       |
| aio.customLivenessProbe                           | object | `{}`                       | Custom liveness probe that overrides the default one                                                                        |
| aio.customReadinessProbe                          | object | `{}`                       | Custom readiness probe that overrides the default one                                                                       |
| aio.customStartupProbe                            | object | `{}`                       | Custom startup probe that overrides the default one                                                                         |
| aio.extraEnvVars                                  | list   | `[]`                       | Array of extra environment variables to be added to Hoppscotch containers                                                   |
| aio.extraEnvVarsCM                                | string | `""`                       | Name of existing ConfigMap containing extra environment variables                                                           |
| aio.extraEnvVarsSecret                            | string | `""`                       | Name of existing Secret containing extra environment variables                                                              |
| aio.resourcesPreset                               | string | `"small"`                  | Set container resources according to one common preset (allowed values: nano, micro, small, medium, large, xlarge, 2xlarge) |
| aio.resources                                     | object | `{}`                       | Set container resources for Hoppscotch (overrides resourcesPreset)                                                          |
| aio.podAnnotations                                | object | `{}`                       | Annotations to add to Hoppscotch pods                                                                                       |
| aio.podLabels                                     | object | `{}`                       | Labels to add to Hoppscotch pods                                                                                            |
| aio.podSecurityContext                            | object | `{}`                       | Security context for Hoppscotch pods                                                                                        |
| aio.securityContext                               | object | `{}`                       | Security context for Hoppscotch containers                                                                                  |
| aio.updateStrategy.type                           | string | `"RollingUpdate"`          | Deployment update strategy type (RollingUpdate or Recreate)                                                                 |
| aio.pdb.create                                    | bool   | `false`                    | Create PodDisruptionBudget for Hoppscotch deployment                                                                        |
| aio.pdb.minAvailable                              | string | `""`                       | Minimum number of available pods during disruptions                                                                         |
| aio.pdb.maxUnavailable                            | string | `""`                       | Maximum number of unavailable pods during disruptions                                                                       |
| aio.autoscaling.enabled                           | bool   | `false`                    | Enable autoscaling for Hoppscotch deployment                                                                                |
| aio.autoscaling.minReplicas                       | int    | `1`                        | Minimum number of Hoppscotch replicas                                                                                       |
| aio.autoscaling.maxReplicas                       | int    | `100`                      | Maximum number of Hoppscotch replicas                                                                                       |
| aio.autoscaling.targetCPUUtilizationPercentage    | int    | `80`                       | Target CPU utilization percentage for autoscaling                                                                           |
| aio.autoscaling.targetMemoryUtilizationPercentage | int    | `80`                       | Target memory utilization percentage for autoscaling                                                                        |
| aio.nodeSelector                                  | object | `{}`                       | Node labels for Hoppscotch pods assignment                                                                                  |
| aio.tolerations                                   | list   | `[]`                       | Tolerations for Hoppscotch pods assignment                                                                                  |
| aio.affinity                                      | object | `{}`                       | Affinity for Hoppscotch pods assignment                                                                                     |
| aio.topologySpreadConstraints                     | list   | `[]`                       | Topology spread constraints for Hoppscotch pods assignment                                                                  |
| aio.volumes                                       | list   | `[]`                       | Extra volumes to add to Hoppscotch deployment                                                                               |
| aio.volumeMounts                                  | list   | `[]`                       | Extra volume mounts to add to Hoppscotch containers                                                                         |
| aio.service.type                                  | string | `"ClusterIP"`              | Kubernetes service type                                                                                                     |
| aio.service.ports.http                            | int    | `80`                       | Service HTTP port                                                                                                           |
| aio.service.ports.https                           | int    | `443`                      | Service HTTPS port                                                                                                          |
| aio.service.ports.frontend                        | int    | `3000`                     | Frontend service HTTP port (when multiport access is enabled)                                                               |
| aio.service.ports.desktop                         | int    | `3200`                     | Desktop service HTTP port (when multiport access is enabled)                                                                |
| aio.service.ports.backend                         | int    | `3170`                     | Backend service HTTP port (when multiport access is enabled)                                                                |
| aio.service.ports.admin                           | int    | `3100`                     | Admin service HTTP port (when multiport access is enabled)                                                                  |
| aio.service.clusterIP                             | string | `""`                       | Static cluster IP address (optional)                                                                                        |
| aio.service.nodePorts.http                        | string | `""`                       | NodePort for HTTP (when service type is NodePort)                                                                           |
| aio.service.nodePorts.https                       | string | `""`                       | NodePort for HTTPS (when service type is NodePort)                                                                          |
| aio.service.nodePorts.frontend                    | string | `""`                       | NodePort for frontend (when service type is NodePort and multiport access is enabled)                                       |
| aio.service.nodePorts.desktop                     | string | `""`                       | NodePort for desktop (when service type is NodePort and multiport access is enabled)                                        |
| aio.service.nodePorts.backend                     | string | `""`                       | NodePort for backend (when service type is NodePort and multiport access is enabled)                                        |
| aio.service.nodePorts.admin                       | string | `""`                       | NodePort for admin (when service type is NodePort and multiport access is enabled)                                          |
| aio.service.loadBalancerIP                        | string | `""`                       | Load balancer IP address (when service type is LoadBalancer)                                                                |
| aio.service.loadBalancerSourceRanges              | list   | `[]`                       | Load balancer source IP ranges (when service type is LoadBalancer)                                                          |
| aio.service.externalTrafficPolicy                 | string | `"Cluster"`                | External traffic policy (Cluster or Local)                                                                                  |
| aio.service.annotations                           | object | `{}`                       | Service annotations                                                                                                         |
| aio.service.sessionAffinity                       | string | `"None"`                   | Session affinity (None or ClientIP)                                                                                         |
| aio.service.sessionAffinityConfig                 | object | `{}`                       | Session affinity configuration                                                                                              |
| aio.service.extraPorts                            | list   | `[]`                       | Extra service ports                                                                                                         |
| aio.networkPolicy.enabled                         | bool   | `false`                    | Enable NetworkPolicy for Hoppscotch pods                                                                                    |
| aio.networkPolicy.allowExternal                   | bool   | `true`                     | Allow external traffic to Hoppscotch pods                                                                                   |
| aio.networkPolicy.allowExternalEgress             | bool   | `true`                     | Allow external egress traffic from Hoppscotch pods                                                                          |
| aio.networkPolicy.addExternalClientAccess         | bool   | `true`                     | Add external client access to NetworkPolicy                                                                                 |
| aio.networkPolicy.extraIngress                    | list   | `[]`                       | Extra ingress rules for NetworkPolicy                                                                                       |
| aio.networkPolicy.extraEgress                     | list   | `[]`                       | Extra egress rules for NetworkPolicy                                                                                        |
| aio.networkPolicy.ingressPodMatchLabels           | object | `{}`                       | Pod selector labels for ingress rules                                                                                       |
| aio.networkPolicy.ingressNSMatchLabels            | object | `{}`                       | Namespace selector labels for ingress rules                                                                                 |
| aio.networkPolicy.ingressNSPodMatchLabels         | object | `{}`                       | Namespace pod selector labels for ingress rules                                                                             |
| aio.ingress.enabled                               | bool   | `false`                    | Enable ingress for Hoppscotch                                                                                               |
| aio.ingress.ingressClassName                      | string | `""`                       | Ingress class name                                                                                                          |
| aio.ingress.hostname                              | string | `"hoppscotch.local"`       | Ingress hostname                                                                                                            |
| aio.ingress.path                                  | string | `"/"`                      | Ingress path                                                                                                                |
| aio.ingress.pathType                              | string | `"ImplementationSpecific"` | Ingress path type                                                                                                           |
| aio.ingress.apiVersion                            | string | `""`                       | Ingress API version                                                                                                         |
| aio.ingress.annotations                           | object | `{}`                       | Ingress annotations                                                                                                         |
| aio.ingress.tls                                   | bool   | `false`                    | Enable TLS for ingress                                                                                                      |
| aio.ingress.selfSigned                            | bool   | `false`                    | Create self-signed TLS certificates                                                                                         |
| aio.ingress.extraHosts                            | list   | `[]`                       | Extra hostnames for ingress                                                                                                 |
| aio.ingress.extraPaths                            | list   | `[]`                       | Extra paths for ingress                                                                                                     |
| aio.ingress.extraTls                              | list   | `[]`                       | Extra TLS configurations for ingress                                                                                        |
| aio.ingress.secrets                               | list   | `[]`                       | TLS secrets for ingress                                                                                                     |
| aio.ingress.extraRules                            | list   | `[]`                       | Extra ingress rules                                                                                                         |
| aio.route.enabled                                 | bool   | `false`                    | Enable OpenShift Route for Hoppscotch (OpenShift only, alternative to ingress)                                              |
| aio.route.host                                    | string | `""`                       | Route hostname (auto-assigned by OpenShift when left empty)                                                                 |
| aio.route.path                                    | string | `""`                       | Route path                                                                                                                  |
| aio.route.targetPort                              | string | `"http"`                   | Service target port name or number the Route forwards to                                                                    |
| aio.route.wildcardPolicy                          | string | `"None"`                   | Route wildcard policy (None or Subdomain)                                                                                   |
| aio.route.annotations                             | object | `{}`                       | Route annotations                                                                                                           |
| aio.route.tls.enabled                             | bool   | `true`                     | Enable TLS for the Route                                                                                                    |
| aio.route.tls.termination                         | string | `"edge"`                   | TLS termination type (edge, passthrough or reencrypt)                                                                       |
| aio.route.tls.insecureEdgeTerminationPolicy       | string | `"Redirect"`               | Insecure traffic policy (None, Allow or Redirect)                                                                           |
| aio.persistence.enabled                           | bool   | `false`                    | Enable persistent storage for Hoppscotch                                                                                    |
| aio.persistence.storageClass                      | string | `""`                       | Storage class for persistent volume                                                                                         |
| aio.persistence.accessModes                       | list   | `["ReadWriteOnce"]`        | Access modes for persistent volume                                                                                          |
| aio.persistence.size                              | string | `"8Gi"`                    | Size of persistent volume                                                                                                   |
| aio.persistence.mountPath                         | string | `"/hoppscotch/data"`       | Mount path for persistent volume                                                                                            |
| aio.persistence.subPath                           | string | `""`                       | Subpath within persistent volume                                                                                            |
| aio.persistence.annotations                       | object | `{}`                       | Annotations for persistent volume claim                                                                                     |
| aio.persistence.dataSource                        | object | `{}`                       | Data source for persistent volume                                                                                           |
| aio.persistence.existingClaim                     | string | `""`                       | Use existing persistent volume claim                                                                                        |
| aio.persistence.selector                          | object | `{}`                       | Selector for persistent volume                                                                                              |
| aio.metrics.enabled                               | bool   | `false`                    | Enable metrics collection for Hoppscotch                                                                                    |
| aio.metrics.serviceMonitor.enabled                | bool   | `false`                    | Enable ServiceMonitor for Prometheus monitoring                                                                             |
| aio.metrics.serviceMonitor.namespace              | string | `""`                       | Namespace for ServiceMonitor (defaults to release namespace)                                                                |
| aio.metrics.serviceMonitor.annotations            | object | `{}`                       | ServiceMonitor annotations                                                                                                  |
| aio.metrics.serviceMonitor.labels                 | object | `{}`                       | ServiceMonitor labels                                                                                                       |
| aio.metrics.serviceMonitor.jobLabel               | string | `""`                       | ServiceMonitor job label                                                                                                    |
| aio.metrics.serviceMonitor.honorLabels            | bool   | `false`                    | Honor labels from target                                                                                                    |
| aio.metrics.serviceMonitor.interval               | string | `""`                       | ServiceMonitor scrape interval                                                                                              |
| aio.metrics.serviceMonitor.scrapeTimeout          | string | `""`                       | ServiceMonitor scrape timeout                                                                                               |
| aio.metrics.serviceMonitor.tlsConfig              | object | `{}`                       | ServiceMonitor TLS configuration                                                                                            |
| aio.metrics.serviceMonitor.metricsRelabelings     | list   | `[]`                       | ServiceMonitor metrics relabelings                                                                                          |
| aio.metrics.serviceMonitor.relabelings            | list   | `[]`                       | ServiceMonitor relabelings                                                                                                  |
| aio.metrics.serviceMonitor.selector               | object | `{}`                       | ServiceMonitor selector                                                                                                     |

### Hoppscotch Frontend Container Parameters

| Key                                                    | Type   | Default                            | Description                                                                                                                 |
| ------------------------------------------------------ | ------ | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| frontend.image.repository                              | string | `"hoppscotch/hoppscotch-frontend"` | Hoppscotch image repository                                                                                                 |
| frontend.image.pullPolicy                              | string | `"IfNotPresent"`                   | Hoppscotch image pull policy                                                                                                |
| frontend.image.tag                                     | string | `""`                               | Hoppscotch image tag                                                                                                        |
| frontend.replicaCount                                  | int    | `1`                                | Number of Hoppscotch replicas                                                                                               |
| frontend.containerPorts.http                           | int    | `80`                               | Hoppscotch HTTP container port                                                                                              |
| frontend.containerPorts.https                          | int    | `443`                              | Hoppscotch HTTPS container port                                                                                             |
| frontend.readinessProbe.enabled                        | bool   | `true`                             | Enable readiness probe                                                                                                      |
| frontend.readinessProbe.initialDelaySeconds            | int    | `0`                                | Initial delay seconds for readiness probe                                                                                   |
| frontend.readinessProbe.periodSeconds                  | int    | `10`                               | Period seconds for readiness probe                                                                                          |
| frontend.readinessProbe.timeoutSeconds                 | int    | `1`                                | Timeout seconds for readiness probe                                                                                         |
| frontend.readinessProbe.failureThreshold               | int    | `3`                                | Failure threshold for readiness probe                                                                                       |
| frontend.readinessProbe.successThreshold               | int    | `1`                                | Success threshold for readiness probe                                                                                       |
| frontend.customLivenessProbe                           | object | `{}`                               | Custom liveness probe that overrides the default one                                                                        |
| frontend.customReadinessProbe                          | object | `{}`                               | Custom readiness probe that overrides the default one                                                                       |
| frontend.customStartupProbe                            | object | `{}`                               | Custom startup probe that overrides the default one                                                                         |
| frontend.extraEnvVars                                  | list   | `[]`                               | Array of extra environment variables to be added to Hoppscotch containers                                                   |
| frontend.extraEnvVarsCM                                | string | `""`                               | Name of existing ConfigMap containing extra environment variables                                                           |
| frontend.extraEnvVarsSecret                            | string | `""`                               | Name of existing Secret containing extra environment variables                                                              |
| frontend.resourcesPreset                               | string | `"small"`                          | Set container resources according to one common preset (allowed values: nano, micro, small, medium, large, xlarge, 2xlarge) |
| frontend.resources                                     | object | `{}`                               | Set container resources for Hoppscotch (overrides resourcesPreset)                                                          |
| frontend.podAnnotations                                | object | `{}`                               | Annotations to add to Hoppscotch pods                                                                                       |
| frontend.podLabels                                     | object | `{}`                               | Labels to add to Hoppscotch pods                                                                                            |
| frontend.podSecurityContext                            | object | `{}`                               | Security context for Hoppscotch pods                                                                                        |
| frontend.securityContext                               | object | `{}`                               | Security context for Hoppscotch containers                                                                                  |
| frontend.updateStrategy.type                           | string | `"RollingUpdate"`                  | Deployment update strategy type (RollingUpdate or Recreate)                                                                 |
| frontend.pdb.create                                    | bool   | `false`                            | Create PodDisruptionBudget for Hoppscotch deployment                                                                        |
| frontend.pdb.minAvailable                              | string | `""`                               | Minimum number of available pods during disruptions                                                                         |
| frontend.pdb.maxUnavailable                            | string | `""`                               | Maximum number of unavailable pods during disruptions                                                                       |
| frontend.autoscaling.enabled                           | bool   | `false`                            | Enable autoscaling for Hoppscotch deployment                                                                                |
| frontend.autoscaling.minReplicas                       | int    | `1`                                | Minimum number of Hoppscotch replicas                                                                                       |
| frontend.autoscaling.maxReplicas                       | int    | `100`                              | Maximum number of Hoppscotch replicas                                                                                       |
| frontend.autoscaling.targetCPUUtilizationPercentage    | int    | `80`                               | Target CPU utilization percentage for autoscaling                                                                           |
| frontend.autoscaling.targetMemoryUtilizationPercentage | int    | `80`                               | Target memory utilization percentage for autoscaling                                                                        |
| frontend.nodeSelector                                  | object | `{}`                               | Node labels for Hoppscotch pods assignment                                                                                  |
| frontend.tolerations                                   | list   | `[]`                               | Tolerations for Hoppscotch pods assignment                                                                                  |
| frontend.affinity                                      | object | `{}`                               | Affinity for Hoppscotch pods assignment                                                                                     |
| frontend.topologySpreadConstraints                     | list   | `[]`                               | Topology spread constraints for Hoppscotch pods assignment                                                                  |
| frontend.volumes                                       | list   | `[]`                               | Extra volumes to add to Hoppscotch deployment                                                                               |
| frontend.volumeMounts                                  | list   | `[]`                               | Extra volume mounts to add to Hoppscotch containers                                                                         |
| frontend.service.type                                  | string | `"ClusterIP"`                      | Kubernetes service type                                                                                                     |
| frontend.service.ports.http                            | int    | `80`                               | Service HTTP port                                                                                                           |
| frontend.service.ports.https                           | int    | `443`                              | Service HTTPS port                                                                                                          |
| frontend.service.clusterIP                             | string | `""`                               | Static cluster IP address (optional)                                                                                        |
| frontend.service.nodePorts.http                        | string | `""`                               | NodePort for HTTP (when service type is NodePort)                                                                           |
| frontend.service.nodePorts.https                       | string | `""`                               | NodePort for HTTPS (when service type is NodePort)                                                                          |
| frontend.service.loadBalancerIP                        | string | `""`                               | Load balancer IP address (when service type is LoadBalancer)                                                                |
| frontend.service.loadBalancerSourceRanges              | list   | `[]`                               | Load balancer source IP ranges (when service type is LoadBalancer)                                                          |
| frontend.service.externalTrafficPolicy                 | string | `"Cluster"`                        | External traffic policy (Cluster or Local)                                                                                  |
| frontend.service.annotations                           | object | `{}`                               | Service annotations                                                                                                         |
| frontend.service.sessionAffinity                       | string | `"None"`                           | Session affinity (None or ClientIP)                                                                                         |
| frontend.service.sessionAffinityConfig                 | object | `{}`                               | Session affinity configuration                                                                                              |
| frontend.service.extraPorts                            | list   | `[]`                               | Extra service ports                                                                                                         |
| frontend.networkPolicy.enabled                         | bool   | `false`                            | Enable NetworkPolicy for Hoppscotch pods                                                                                    |
| frontend.networkPolicy.allowExternal                   | bool   | `true`                             | Allow external traffic to Hoppscotch pods                                                                                   |
| frontend.networkPolicy.allowExternalEgress             | bool   | `true`                             | Allow external egress traffic from Hoppscotch pods                                                                          |
| frontend.networkPolicy.addExternalClientAccess         | bool   | `true`                             | Add external client access to NetworkPolicy                                                                                 |
| frontend.networkPolicy.extraIngress                    | list   | `[]`                               | Extra ingress rules for NetworkPolicy                                                                                       |
| frontend.networkPolicy.extraEgress                     | list   | `[]`                               | Extra egress rules for NetworkPolicy                                                                                        |
| frontend.networkPolicy.ingressPodMatchLabels           | object | `{}`                               | Pod selector labels for ingress rules                                                                                       |
| frontend.networkPolicy.ingressNSMatchLabels            | object | `{}`                               | Namespace selector labels for ingress rules                                                                                 |
| frontend.networkPolicy.ingressNSPodMatchLabels         | object | `{}`                               | Namespace pod selector labels for ingress rules                                                                             |
| frontend.ingress.enabled                               | bool   | `false`                            | Enable ingress for Hoppscotch                                                                                               |
| frontend.ingress.ingressClassName                      | string | `""`                               | Ingress class name                                                                                                          |
| frontend.ingress.hostname                              | string | `"hoppscotch-frontend.local"`      | Ingress hostname                                                                                                            |
| frontend.ingress.path                                  | string | `"/"`                              | Ingress path                                                                                                                |
| frontend.ingress.pathType                              | string | `"ImplementationSpecific"`         | Ingress path type                                                                                                           |
| frontend.ingress.apiVersion                            | string | `""`                               | Ingress API version                                                                                                         |
| frontend.ingress.annotations                           | object | `{}`                               | Ingress annotations                                                                                                         |
| frontend.ingress.tls                                   | bool   | `false`                            | Enable TLS for ingress                                                                                                      |
| frontend.ingress.selfSigned                            | bool   | `false`                            | Create self-signed TLS certificates                                                                                         |
| frontend.ingress.extraHosts                            | list   | `[]`                               | Extra hostnames for ingress                                                                                                 |
| frontend.ingress.extraPaths                            | list   | `[]`                               | Extra paths for ingress                                                                                                     |
| frontend.ingress.extraTls                              | list   | `[]`                               | Extra TLS configurations for ingress                                                                                        |
| frontend.ingress.secrets                               | list   | `[]`                               | TLS secrets for ingress                                                                                                     |
| frontend.ingress.extraRules                            | list   | `[]`                               | Extra ingress rules                                                                                                         |
| frontend.route.enabled                                 | bool   | `false`                            | Enable OpenShift Route for Hoppscotch (OpenShift only, alternative to ingress)                                              |
| frontend.route.host                                    | string | `""`                               | Route hostname (auto-assigned by OpenShift when left empty)                                                                 |
| frontend.route.path                                    | string | `""`                               | Route path                                                                                                                  |
| frontend.route.targetPort                              | string | `"http"`                           | Service target port name or number the Route forwards to                                                                    |
| frontend.route.wildcardPolicy                          | string | `"None"`                           | Route wildcard policy (None or Subdomain)                                                                                   |
| frontend.route.annotations                             | object | `{}`                               | Route annotations                                                                                                           |
| frontend.route.tls.enabled                             | bool   | `true`                             | Enable TLS for the Route                                                                                                    |
| frontend.route.tls.termination                         | string | `"edge"`                           | TLS termination type (edge, passthrough or reencrypt)                                                                       |
| frontend.route.tls.insecureEdgeTerminationPolicy       | string | `"Redirect"`                       | Insecure traffic policy (None, Allow or Redirect)                                                                           |
| frontend.persistence.enabled                           | bool   | `false`                            | Enable persistent storage for Hoppscotch                                                                                    |
| frontend.persistence.storageClass                      | string | `""`                               | Storage class for persistent volume                                                                                         |
| frontend.persistence.accessModes                       | list   | `["ReadWriteOnce"]`                | Access modes for persistent volume                                                                                          |
| frontend.persistence.size                              | string | `"8Gi"`                            | Size of persistent volume                                                                                                   |
| frontend.persistence.mountPath                         | string | `"/hoppscotch/data"`               | Mount path for persistent volume                                                                                            |
| frontend.persistence.subPath                           | string | `""`                               | Subpath within persistent volume                                                                                            |
| frontend.persistence.annotations                       | object | `{}`                               | Annotations for persistent volume claim                                                                                     |
| frontend.persistence.dataSource                        | object | `{}`                               | Data source for persistent volume                                                                                           |
| frontend.persistence.existingClaim                     | string | `""`                               | Use existing persistent volume claim                                                                                        |
| frontend.persistence.selector                          | object | `{}`                               | Selector for persistent volume                                                                                              |
| frontend.metrics.enabled                               | bool   | `false`                            | Enable metrics collection for Hoppscotch                                                                                    |
| frontend.metrics.serviceMonitor.enabled                | bool   | `false`                            | Enable ServiceMonitor for Prometheus monitoring                                                                             |
| frontend.metrics.serviceMonitor.namespace              | string | `""`                               | Namespace for ServiceMonitor (defaults to release namespace)                                                                |
| frontend.metrics.serviceMonitor.annotations            | object | `{}`                               | ServiceMonitor annotations                                                                                                  |
| frontend.metrics.serviceMonitor.labels                 | object | `{}`                               | ServiceMonitor labels                                                                                                       |
| frontend.metrics.serviceMonitor.jobLabel               | string | `""`                               | ServiceMonitor job label                                                                                                    |
| frontend.metrics.serviceMonitor.honorLabels            | bool   | `false`                            | Honor labels from target                                                                                                    |
| frontend.metrics.serviceMonitor.interval               | string | `""`                               | ServiceMonitor scrape interval                                                                                              |
| frontend.metrics.serviceMonitor.scrapeTimeout          | string | `""`                               | ServiceMonitor scrape timeout                                                                                               |
| frontend.metrics.serviceMonitor.tlsConfig              | object | `{}`                               | ServiceMonitor TLS configuration                                                                                            |
| frontend.metrics.serviceMonitor.metricsRelabelings     | list   | `[]`                               | ServiceMonitor metrics relabelings                                                                                          |
| frontend.metrics.serviceMonitor.relabelings            | list   | `[]`                               | ServiceMonitor relabelings                                                                                                  |
| frontend.metrics.serviceMonitor.selector               | object | `{}`                               | ServiceMonitor selector                                                                                                     |

### Hoppscotch Backend Container Parameters

| Key                                                   | Type   | Default                           | Description                                                                                                                 |
| ----------------------------------------------------- | ------ | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| backend.image.repository                              | string | `"hoppscotch/hoppscotch-backend"` | Hoppscotch image repository                                                                                                 |
| backend.image.pullPolicy                              | string | `"IfNotPresent"`                  | Hoppscotch image pull policy                                                                                                |
| backend.image.tag                                     | string | `""`                              | Hoppscotch image tag                                                                                                        |
| backend.replicaCount                                  | int    | `1`                               | Number of Hoppscotch replicas                                                                                               |
| backend.containerPorts.http                           | int    | `80`                              | Hoppscotch HTTP container port                                                                                              |
| backend.containerPorts.https                          | int    | `443`                             | Hoppscotch HTTPS container port                                                                                             |
| backend.readinessProbe.enabled                        | bool   | `true`                            | Enable readiness probe                                                                                                      |
| backend.readinessProbe.initialDelaySeconds            | int    | `0`                               | Initial delay seconds for readiness probe                                                                                   |
| backend.readinessProbe.periodSeconds                  | int    | `10`                              | Period seconds for readiness probe                                                                                          |
| backend.readinessProbe.timeoutSeconds                 | int    | `1`                               | Timeout seconds for readiness probe                                                                                         |
| backend.readinessProbe.failureThreshold               | int    | `3`                               | Failure threshold for readiness probe                                                                                       |
| backend.readinessProbe.successThreshold               | int    | `1`                               | Success threshold for readiness probe                                                                                       |
| backend.customLivenessProbe                           | object | `{}`                              | Custom liveness probe that overrides the default one                                                                        |
| backend.customReadinessProbe                          | object | `{}`                              | Custom readiness probe that overrides the default one                                                                       |
| backend.customStartupProbe                            | object | `{}`                              | Custom startup probe that overrides the default one                                                                         |
| backend.extraEnvVars                                  | list   | `[]`                              | Array of extra environment variables to be added to Hoppscotch containers                                                   |
| backend.extraEnvVarsCM                                | string | `""`                              | Name of existing ConfigMap containing extra environment variables                                                           |
| backend.extraEnvVarsSecret                            | string | `""`                              | Name of existing Secret containing extra environment variables                                                              |
| backend.resourcesPreset                               | string | `"small"`                         | Set container resources according to one common preset (allowed values: nano, micro, small, medium, large, xlarge, 2xlarge) |
| backend.resources                                     | object | `{}`                              | Set container resources for Hoppscotch (overrides resourcesPreset)                                                          |
| backend.podAnnotations                                | object | `{}`                              | Annotations to add to Hoppscotch pods                                                                                       |
| backend.podLabels                                     | object | `{}`                              | Labels to add to Hoppscotch pods                                                                                            |
| backend.podSecurityContext                            | object | `{}`                              | Security context for Hoppscotch pods                                                                                        |
| backend.securityContext                               | object | `{}`                              | Security context for Hoppscotch containers                                                                                  |
| backend.updateStrategy.type                           | string | `"RollingUpdate"`                 | Deployment update strategy type (RollingUpdate or Recreate)                                                                 |
| backend.pdb.create                                    | bool   | `false`                           | Create PodDisruptionBudget for Hoppscotch deployment                                                                        |
| backend.pdb.minAvailable                              | string | `""`                              | Minimum number of available pods during disruptions                                                                         |
| backend.pdb.maxUnavailable                            | string | `""`                              | Maximum number of unavailable pods during disruptions                                                                       |
| backend.autoscaling.enabled                           | bool   | `false`                           | Enable autoscaling for Hoppscotch deployment                                                                                |
| backend.autoscaling.minReplicas                       | int    | `1`                               | Minimum number of Hoppscotch replicas                                                                                       |
| backend.autoscaling.maxReplicas                       | int    | `100`                             | Maximum number of Hoppscotch replicas                                                                                       |
| backend.autoscaling.targetCPUUtilizationPercentage    | int    | `80`                              | Target CPU utilization percentage for autoscaling                                                                           |
| backend.autoscaling.targetMemoryUtilizationPercentage | int    | `80`                              | Target memory utilization percentage for autoscaling                                                                        |
| backend.nodeSelector                                  | object | `{}`                              | Node labels for Hoppscotch pods assignment                                                                                  |
| backend.tolerations                                   | list   | `[]`                              | Tolerations for Hoppscotch pods assignment                                                                                  |
| backend.affinity                                      | object | `{}`                              | Affinity for Hoppscotch pods assignment                                                                                     |
| backend.topologySpreadConstraints                     | list   | `[]`                              | Topology spread constraints for Hoppscotch pods assignment                                                                  |
| backend.volumes                                       | list   | `[]`                              | Extra volumes to add to Hoppscotch deployment                                                                               |
| backend.volumeMounts                                  | list   | `[]`                              | Extra volume mounts to add to Hoppscotch containers                                                                         |
| backend.service.type                                  | string | `"ClusterIP"`                     | Kubernetes service type                                                                                                     |
| backend.service.ports.http                            | int    | `80`                              | Service HTTP port                                                                                                           |
| backend.service.ports.https                           | int    | `443`                             | Service HTTPS port                                                                                                          |
| backend.service.clusterIP                             | string | `""`                              | Static cluster IP address (optional)                                                                                        |
| backend.service.nodePorts.http                        | string | `""`                              | NodePort for HTTP (when service type is NodePort)                                                                           |
| backend.service.nodePorts.https                       | string | `""`                              | NodePort for HTTPS (when service type is NodePort)                                                                          |
| backend.service.loadBalancerIP                        | string | `""`                              | Load balancer IP address (when service type is LoadBalancer)                                                                |
| backend.service.loadBalancerSourceRanges              | list   | `[]`                              | Load balancer source IP ranges (when service type is LoadBalancer)                                                          |
| backend.service.externalTrafficPolicy                 | string | `"Cluster"`                       | External traffic policy (Cluster or Local)                                                                                  |
| backend.service.annotations                           | object | `{}`                              | Service annotations                                                                                                         |
| backend.service.sessionAffinity                       | string | `"None"`                          | Session affinity (None or ClientIP)                                                                                         |
| backend.service.sessionAffinityConfig                 | object | `{}`                              | Session affinity configuration                                                                                              |
| backend.service.extraPorts                            | list   | `[]`                              | Extra service ports                                                                                                         |
| backend.networkPolicy.enabled                         | bool   | `false`                           | Enable NetworkPolicy for Hoppscotch pods                                                                                    |
| backend.networkPolicy.allowExternal                   | bool   | `true`                            | Allow external traffic to Hoppscotch pods                                                                                   |
| backend.networkPolicy.allowExternalEgress             | bool   | `true`                            | Allow external egress traffic from Hoppscotch pods                                                                          |
| backend.networkPolicy.addExternalClientAccess         | bool   | `true`                            | Add external client access to NetworkPolicy                                                                                 |
| backend.networkPolicy.extraIngress                    | list   | `[]`                              | Extra ingress rules for NetworkPolicy                                                                                       |
| backend.networkPolicy.extraEgress                     | list   | `[]`                              | Extra egress rules for NetworkPolicy                                                                                        |
| backend.networkPolicy.ingressPodMatchLabels           | object | `{}`                              | Pod selector labels for ingress rules                                                                                       |
| backend.networkPolicy.ingressNSMatchLabels            | object | `{}`                              | Namespace selector labels for ingress rules                                                                                 |
| backend.networkPolicy.ingressNSPodMatchLabels         | object | `{}`                              | Namespace pod selector labels for ingress rules                                                                             |
| backend.ingress.enabled                               | bool   | `false`                           | Enable ingress for Hoppscotch                                                                                               |
| backend.ingress.ingressClassName                      | string | `""`                              | Ingress class name                                                                                                          |
| backend.ingress.hostname                              | string | `"hoppscotch-frontend.local"`     | Ingress hostname                                                                                                            |
| backend.ingress.path                                  | string | `"/"`                             | Ingress path                                                                                                                |
| backend.ingress.pathType                              | string | `"ImplementationSpecific"`        | Ingress path type                                                                                                           |
| backend.ingress.apiVersion                            | string | `""`                              | Ingress API version                                                                                                         |
| backend.ingress.annotations                           | object | `{}`                              | Ingress annotations                                                                                                         |
| backend.ingress.tls                                   | bool   | `false`                           | Enable TLS for ingress                                                                                                      |
| backend.ingress.selfSigned                            | bool   | `false`                           | Create self-signed TLS certificates                                                                                         |
| backend.ingress.extraHosts                            | list   | `[]`                              | Extra hostnames for ingress                                                                                                 |
| backend.ingress.extraPaths                            | list   | `[]`                              | Extra paths for ingress                                                                                                     |
| backend.ingress.extraTls                              | list   | `[]`                              | Extra TLS configurations for ingress                                                                                        |
| backend.ingress.secrets                               | list   | `[]`                              | TLS secrets for ingress                                                                                                     |
| backend.ingress.extraRules                            | list   | `[]`                              | Extra ingress rules                                                                                                         |
| backend.route.enabled                                 | bool   | `false`                           | Enable OpenShift Route for Hoppscotch (OpenShift only, alternative to ingress)                                              |
| backend.route.host                                    | string | `""`                              | Route hostname (auto-assigned by OpenShift when left empty)                                                                 |
| backend.route.path                                    | string | `""`                              | Route path                                                                                                                  |
| backend.route.targetPort                              | string | `"http"`                          | Service target port name or number the Route forwards to                                                                    |
| backend.route.wildcardPolicy                          | string | `"None"`                          | Route wildcard policy (None or Subdomain)                                                                                   |
| backend.route.annotations                             | object | `{}`                              | Route annotations                                                                                                           |
| backend.route.tls.enabled                             | bool   | `true`                            | Enable TLS for the Route                                                                                                    |
| backend.route.tls.termination                         | string | `"edge"`                          | TLS termination type (edge, passthrough or reencrypt)                                                                       |
| backend.route.tls.insecureEdgeTerminationPolicy       | string | `"Redirect"`                      | Insecure traffic policy (None, Allow or Redirect)                                                                           |
| backend.persistence.enabled                           | bool   | `false`                           | Enable persistent storage for Hoppscotch                                                                                    |
| backend.persistence.storageClass                      | string | `""`                              | Storage class for persistent volume                                                                                         |
| backend.persistence.accessModes                       | list   | `["ReadWriteOnce"]`               | Access modes for persistent volume                                                                                          |
| backend.persistence.size                              | string | `"8Gi"`                           | Size of persistent volume                                                                                                   |
| backend.persistence.mountPath                         | string | `"/hoppscotch/data"`              | Mount path for persistent volume                                                                                            |
| backend.persistence.subPath                           | string | `""`                              | Subpath within persistent volume                                                                                            |
| backend.persistence.annotations                       | object | `{}`                              | Annotations for persistent volume claim                                                                                     |
| backend.persistence.dataSource                        | object | `{}`                              | Data source for persistent volume                                                                                           |
| backend.persistence.existingClaim                     | string | `""`                              | Use existing persistent volume claim                                                                                        |
| backend.persistence.selector                          | object | `{}`                              | Selector for persistent volume                                                                                              |
| backend.metrics.enabled                               | bool   | `false`                           | Enable metrics collection for Hoppscotch                                                                                    |
| backend.metrics.serviceMonitor.enabled                | bool   | `false`                           | Enable ServiceMonitor for Prometheus monitoring                                                                             |
| backend.metrics.serviceMonitor.namespace              | string | `""`                              | Namespace for ServiceMonitor (defaults to release namespace)                                                                |
| backend.metrics.serviceMonitor.annotations            | object | `{}`                              | ServiceMonitor annotations                                                                                                  |
| backend.metrics.serviceMonitor.labels                 | object | `{}`                              | ServiceMonitor labels                                                                                                       |
| backend.metrics.serviceMonitor.jobLabel               | string | `""`                              | ServiceMonitor job label                                                                                                    |
| backend.metrics.serviceMonitor.honorLabels            | bool   | `false`                           | Honor labels from target                                                                                                    |
| backend.metrics.serviceMonitor.interval               | string | `""`                              | ServiceMonitor scrape interval                                                                                              |
| backend.metrics.serviceMonitor.scrapeTimeout          | string | `""`                              | ServiceMonitor scrape timeout                                                                                               |
| backend.metrics.serviceMonitor.tlsConfig              | object | `{}`                              | ServiceMonitor TLS configuration                                                                                            |
| backend.metrics.serviceMonitor.metricsRelabelings     | list   | `[]`                              | ServiceMonitor metrics relabelings                                                                                          |
| backend.metrics.serviceMonitor.relabelings            | list   | `[]`                              | ServiceMonitor relabelings                                                                                                  |
| backend.metrics.serviceMonitor.selector               | object | `{}`                              | ServiceMonitor selector                                                                                                     |

### Hoppscotch Admin Container Parameters

| Key                                                 | Type   | Default                         | Description                                                                                                                 |
| --------------------------------------------------- | ------ | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| admin.image.repository                              | string | `"hoppscotch/hoppscotch-admin"` | Hoppscotch image repository                                                                                                 |
| admin.image.pullPolicy                              | string | `"IfNotPresent"`                | Hoppscotch image pull policy                                                                                                |
| admin.image.tag                                     | string | `""`                            | Hoppscotch image tag                                                                                                        |
| admin.replicaCount                                  | int    | `1`                             | Number of Hoppscotch replicas                                                                                               |
| admin.containerPorts.http                           | int    | `80`                            | Hoppscotch HTTP container port                                                                                              |
| admin.containerPorts.https                          | int    | `443`                           | Hoppscotch HTTPS container port                                                                                             |
| admin.readinessProbe.enabled                        | bool   | `true`                          | Enable readiness probe                                                                                                      |
| admin.readinessProbe.initialDelaySeconds            | int    | `0`                             | Initial delay seconds for readiness probe                                                                                   |
| admin.readinessProbe.periodSeconds                  | int    | `10`                            | Period seconds for readiness probe                                                                                          |
| admin.readinessProbe.timeoutSeconds                 | int    | `1`                             | Timeout seconds for readiness probe                                                                                         |
| admin.readinessProbe.failureThreshold               | int    | `3`                             | Failure threshold for readiness probe                                                                                       |
| admin.readinessProbe.successThreshold               | int    | `1`                             | Success threshold for readiness probe                                                                                       |
| admin.customLivenessProbe                           | object | `{}`                            | Custom liveness probe that overrides the default one                                                                        |
| admin.customReadinessProbe                          | object | `{}`                            | Custom readiness probe that overrides the default one                                                                       |
| admin.customStartupProbe                            | object | `{}`                            | Custom startup probe that overrides the default one                                                                         |
| admin.extraEnvVars                                  | list   | `[]`                            | Array of extra environment variables to be added to Hoppscotch containers                                                   |
| admin.extraEnvVarsCM                                | string | `""`                            | Name of existing ConfigMap containing extra environment variables                                                           |
| admin.extraEnvVarsSecret                            | string | `""`                            | Name of existing Secret containing extra environment variables                                                              |
| admin.resourcesPreset                               | string | `"small"`                       | Set container resources according to one common preset (allowed values: nano, micro, small, medium, large, xlarge, 2xlarge) |
| admin.resources                                     | object | `{}`                            | Set container resources for Hoppscotch (overrides resourcesPreset)                                                          |
| admin.podAnnotations                                | object | `{}`                            | Annotations to add to Hoppscotch pods                                                                                       |
| admin.podLabels                                     | object | `{}`                            | Labels to add to Hoppscotch pods                                                                                            |
| admin.podSecurityContext                            | object | `{}`                            | Security context for Hoppscotch pods                                                                                        |
| admin.securityContext                               | object | `{}`                            | Security context for Hoppscotch containers                                                                                  |
| admin.updateStrategy.type                           | string | `"RollingUpdate"`               | Deployment update strategy type (RollingUpdate or Recreate)                                                                 |
| admin.pdb.create                                    | bool   | `false`                         | Create PodDisruptionBudget for Hoppscotch deployment                                                                        |
| admin.pdb.minAvailable                              | string | `""`                            | Minimum number of available pods during disruptions                                                                         |
| admin.pdb.maxUnavailable                            | string | `""`                            | Maximum number of unavailable pods during disruptions                                                                       |
| admin.autoscaling.enabled                           | bool   | `false`                         | Enable autoscaling for Hoppscotch deployment                                                                                |
| admin.autoscaling.minReplicas                       | int    | `1`                             | Minimum number of Hoppscotch replicas                                                                                       |
| admin.autoscaling.maxReplicas                       | int    | `100`                           | Maximum number of Hoppscotch replicas                                                                                       |
| admin.autoscaling.targetCPUUtilizationPercentage    | int    | `80`                            | Target CPU utilization percentage for autoscaling                                                                           |
| admin.autoscaling.targetMemoryUtilizationPercentage | int    | `80`                            | Target memory utilization percentage for autoscaling                                                                        |
| admin.nodeSelector                                  | object | `{}`                            | Node labels for Hoppscotch pods assignment                                                                                  |
| admin.tolerations                                   | list   | `[]`                            | Tolerations for Hoppscotch pods assignment                                                                                  |
| admin.affinity                                      | object | `{}`                            | Affinity for Hoppscotch pods assignment                                                                                     |
| admin.topologySpreadConstraints                     | list   | `[]`                            | Topology spread constraints for Hoppscotch pods assignment                                                                  |
| admin.volumes                                       | list   | `[]`                            | Extra volumes to add to Hoppscotch deployment                                                                               |
| admin.volumeMounts                                  | list   | `[]`                            | Extra volume mounts to add to Hoppscotch containers                                                                         |
| admin.service.type                                  | string | `"ClusterIP"`                   | Kubernetes service type                                                                                                     |
| admin.service.ports.http                            | int    | `80`                            | Service HTTP port                                                                                                           |
| admin.service.ports.https                           | int    | `443`                           | Service HTTPS port                                                                                                          |
| admin.service.clusterIP                             | string | `""`                            | Static cluster IP address (optional)                                                                                        |
| admin.service.nodePorts.http                        | string | `""`                            | NodePort for HTTP (when service type is NodePort)                                                                           |
| admin.service.nodePorts.https                       | string | `""`                            | NodePort for HTTPS (when service type is NodePort)                                                                          |
| admin.service.loadBalancerIP                        | string | `""`                            | Load balancer IP address (when service type is LoadBalancer)                                                                |
| admin.service.loadBalancerSourceRanges              | list   | `[]`                            | Load balancer source IP ranges (when service type is LoadBalancer)                                                          |
| admin.service.externalTrafficPolicy                 | string | `"Cluster"`                     | External traffic policy (Cluster or Local)                                                                                  |
| admin.service.annotations                           | object | `{}`                            | Service annotations                                                                                                         |
| admin.service.sessionAffinity                       | string | `"None"`                        | Session affinity (None or ClientIP)                                                                                         |
| admin.service.sessionAffinityConfig                 | object | `{}`                            | Session affinity configuration                                                                                              |
| admin.service.extraPorts                            | list   | `[]`                            | Extra service ports                                                                                                         |
| admin.networkPolicy.enabled                         | bool   | `false`                         | Enable NetworkPolicy for Hoppscotch pods                                                                                    |
| admin.networkPolicy.allowExternal                   | bool   | `true`                          | Allow external traffic to Hoppscotch pods                                                                                   |
| admin.networkPolicy.allowExternalEgress             | bool   | `true`                          | Allow external egress traffic from Hoppscotch pods                                                                          |
| admin.networkPolicy.addExternalClientAccess         | bool   | `true`                          | Add external client access to NetworkPolicy                                                                                 |
| admin.networkPolicy.extraIngress                    | list   | `[]`                            | Extra ingress rules for NetworkPolicy                                                                                       |
| admin.networkPolicy.extraEgress                     | list   | `[]`                            | Extra egress rules for NetworkPolicy                                                                                        |
| admin.networkPolicy.ingressPodMatchLabels           | object | `{}`                            | Pod selector labels for ingress rules                                                                                       |
| admin.networkPolicy.ingressNSMatchLabels            | object | `{}`                            | Namespace selector labels for ingress rules                                                                                 |
| admin.networkPolicy.ingressNSPodMatchLabels         | object | `{}`                            | Namespace pod selector labels for ingress rules                                                                             |
| admin.ingress.enabled                               | bool   | `false`                         | Enable ingress for Hoppscotch                                                                                               |
| admin.ingress.ingressClassName                      | string | `""`                            | Ingress class name                                                                                                          |
| admin.ingress.hostname                              | string | `"hoppscotch-admin.local"`      | Ingress hostname                                                                                                            |
| admin.ingress.path                                  | string | `"/"`                           | Ingress path                                                                                                                |
| admin.ingress.pathType                              | string | `"ImplementationSpecific"`      | Ingress path type                                                                                                           |
| admin.ingress.apiVersion                            | string | `""`                            | Ingress API version                                                                                                         |
| admin.ingress.annotations                           | object | `{}`                            | Ingress annotations                                                                                                         |
| admin.ingress.tls                                   | bool   | `false`                         | Enable TLS for ingress                                                                                                      |
| admin.ingress.selfSigned                            | bool   | `false`                         | Create self-signed TLS certificates                                                                                         |
| admin.ingress.extraHosts                            | list   | `[]`                            | Extra hostnames for ingress                                                                                                 |
| admin.ingress.extraPaths                            | list   | `[]`                            | Extra paths for ingress                                                                                                     |
| admin.ingress.extraTls                              | list   | `[]`                            | Extra TLS configurations for ingress                                                                                        |
| admin.ingress.secrets                               | list   | `[]`                            | TLS secrets for ingress                                                                                                     |
| admin.ingress.extraRules                            | list   | `[]`                            | Extra ingress rules                                                                                                         |
| admin.route.enabled                                 | bool   | `false`                         | Enable OpenShift Route for Hoppscotch (OpenShift only, alternative to ingress)                                              |
| admin.route.host                                    | string | `""`                            | Route hostname (auto-assigned by OpenShift when left empty)                                                                 |
| admin.route.path                                    | string | `""`                            | Route path                                                                                                                  |
| admin.route.targetPort                              | string | `"http"`                        | Service target port name or number the Route forwards to                                                                    |
| admin.route.wildcardPolicy                          | string | `"None"`                        | Route wildcard policy (None or Subdomain)                                                                                   |
| admin.route.annotations                             | object | `{}`                            | Route annotations                                                                                                           |
| admin.route.tls.enabled                             | bool   | `true`                          | Enable TLS for the Route                                                                                                    |
| admin.route.tls.termination                         | string | `"edge"`                        | TLS termination type (edge, passthrough or reencrypt)                                                                       |
| admin.route.tls.insecureEdgeTerminationPolicy       | string | `"Redirect"`                    | Insecure traffic policy (None, Allow or Redirect)                                                                           |
| admin.persistence.enabled                           | bool   | `false`                         | Enable persistent storage for Hoppscotch                                                                                    |
| admin.persistence.storageClass                      | string | `""`                            | Storage class for persistent volume                                                                                         |
| admin.persistence.accessModes                       | list   | `["ReadWriteOnce"]`             | Access modes for persistent volume                                                                                          |
| admin.persistence.size                              | string | `"8Gi"`                         | Size of persistent volume                                                                                                   |
| admin.persistence.mountPath                         | string | `"/hoppscotch/data"`            | Mount path for persistent volume                                                                                            |
| admin.persistence.subPath                           | string | `""`                            | Subpath within persistent volume                                                                                            |
| admin.persistence.annotations                       | object | `{}`                            | Annotations for persistent volume claim                                                                                     |
| admin.persistence.dataSource                        | object | `{}`                            | Data source for persistent volume                                                                                           |
| admin.persistence.existingClaim                     | string | `""`                            | Use existing persistent volume claim                                                                                        |
| admin.persistence.selector                          | object | `{}`                            | Selector for persistent volume                                                                                              |
| admin.metrics.enabled                               | bool   | `false`                         | Enable metrics collection for Hoppscotch                                                                                    |
| admin.metrics.serviceMonitor.enabled                | bool   | `false`                         | Enable ServiceMonitor for Prometheus monitoring                                                                             |
| admin.metrics.serviceMonitor.namespace              | string | `""`                            | Namespace for ServiceMonitor (defaults to release namespace)                                                                |
| admin.metrics.serviceMonitor.annotations            | object | `{}`                            | ServiceMonitor annotations                                                                                                  |
| admin.metrics.serviceMonitor.labels                 | object | `{}`                            | ServiceMonitor labels                                                                                                       |
| admin.metrics.serviceMonitor.jobLabel               | string | `""`                            | ServiceMonitor job label                                                                                                    |
| admin.metrics.serviceMonitor.honorLabels            | bool   | `false`                         | Honor labels from target                                                                                                    |
| admin.metrics.serviceMonitor.interval               | string | `""`                            | ServiceMonitor scrape interval                                                                                              |
| admin.metrics.serviceMonitor.scrapeTimeout          | string | `""`                            | ServiceMonitor scrape timeout                                                                                               |
| admin.metrics.serviceMonitor.tlsConfig              | object | `{}`                            | ServiceMonitor TLS configuration                                                                                            |
| admin.metrics.serviceMonitor.metricsRelabelings     | list   | `[]`                            | ServiceMonitor metrics relabelings                                                                                          |
| admin.metrics.serviceMonitor.relabelings            | list   | `[]`                            | ServiceMonitor relabelings                                                                                                  |
| admin.metrics.serviceMonitor.selector               | object | `{}`                            | ServiceMonitor selector                                                                                                     |

### Hoppscotch Migrations Container Parameters

| Key                                  | Type   | Default   | Description                                                                                                                 |
| ------------------------------------ | ------ | --------- | --------------------------------------------------------------------------------------------------------------------------- |
| migrations.enabled                   | bool   | `true`    | Enable database migrations job                                                                                              |
| migrations.extraEnvVars              | list   | `[]`      | Array of extra environment variables to be added to Hoppscotch containers                                                   |
| migrations.extraEnvVarsCM            | string | `""`      | Name of existing ConfigMap containing extra environment variables                                                           |
| migrations.extraEnvVarsSecret        | string | `""`      | Name of existing Secret containing extra environment variables                                                              |
| migrations.resourcesPreset           | string | `"small"` | Set container resources according to one common preset (allowed values: nano, micro, small, medium, large, xlarge, 2xlarge) |
| migrations.resources                 | object | `{}`      | Set container resources for Hoppscotch (overrides resourcesPreset)                                                          |
| migrations.nodeSelector              | object | `{}`      | Node labels for Hoppscotch pods assignment                                                                                  |
| migrations.tolerations               | list   | `[]`      | Tolerations for Hoppscotch pods assignment                                                                                  |
| migrations.affinity                  | object | `{}`      | Affinity for Hoppscotch pods assignment                                                                                     |
| migrations.topologySpreadConstraints | list   | `[]`      | Topology spread constraints for Hoppscotch pods assignment                                                                  |

### Default Init Containers Parameters

| Key                                                        | Type   | Default          | Description                                                                                                         |
| ---------------------------------------------------------- | ------ | ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| defaultInitContainers.waitForDatabase.enabled              | bool   | `true`           | Enable init container that waits for database to be ready                                                           |
| defaultInitContainers.waitForDatabase.image.repository     | string | `"postgres"`     | Wait for database image repository                                                                                  |
| defaultInitContainers.waitForDatabase.image.pullPolicy     | string | `"IfNotPresent"` | Wait for database image pull policy                                                                                 |
| defaultInitContainers.waitForDatabase.image.tag            | string | `"16-alpine"`    | Wait for database image tag                                                                                         |
| defaultInitContainers.waitForDatabase.extraEnvVars         | list   | `[]`             | Array of extra environment variables to be added to wait for database containers                                    |
| defaultInitContainers.waitForDatabase.extraEnvVarsCM       | string | `""`             | Name of the existing ConfigMap containing extra environment variables to be added to wait for database containers   |
| defaultInitContainers.waitForDatabase.extraEnvVarsSecret   | string | `""`             | Name of existing Secret containing extra environment variables to be added to wait for database containers          |
| defaultInitContainers.waitForMigrations.enabled            | bool   | `true`           | Enable init container that waits for migrations to complete                                                         |
| defaultInitContainers.waitForMigrations.extraEnvVars       | list   | `[]`             | Array of extra environment variables to be added to wait for migrations containers                                  |
| defaultInitContainers.waitForMigrations.extraEnvVarsCM     | string | `""`             | Name of the existing ConfigMap containing extra environment variables to be added to wait for migrations containers |
| defaultInitContainers.waitForMigrations.extraEnvVarsSecret | string | `""`             | Name of existing Secret containing extra environment variables to be added to wait for migrations containers        |

### Mock Server Parameters

| Key                                 | Type   | Default                    | Description                                                                |
| ----------------------------------- | ------ | -------------------------- | -------------------------------------------------------------------------- |
| mockServer.ingress.enabled          | bool   | `false`                    | Enable wildcard ingress for the mock server                                |
| mockServer.ingress.controllerType   | string | `"nginx"`                  | Ingress controller type (nginx, traefik, or alb)                           |
| mockServer.ingress.ingressClassName | string | `""`                       | Ingress class name                                                         |
| mockServer.ingress.hostname         | string | `"mock.hoppscotch.local"`  | Wildcard hostname for mock server ingress (wildcard will be \*.<hostname>) |
| mockServer.ingress.path             | string | `"/"`                      | Ingress path                                                               |
| mockServer.ingress.pathType         | string | `"ImplementationSpecific"` | Ingress path type                                                          |
| mockServer.ingress.annotations      | object | `{}`                       | Additional annotations for the mock server ingress                         |
| mockServer.ingress.tls              | bool   | `false`                    | Enable TLS for mock server ingress                                         |
| mockServer.ingress.selfSigned       | bool   | `false`                    | Create self-signed TLS certificates for mock server ingress                |
| mockServer.ingress.tlsSecret        | string | `""`                       | Existing TLS secret name for mock server ingress (auto-generated if empty) |
| mockServer.ingress.extraTls         | list   | `[]`                       | Extra TLS configurations for mock server ingress                           |
| mockServer.ingress.extraRules       | list   | `[]`                       | Extra ingress rules for mock server ingress                                |

### Other Parameters

| Key                                         | Type   | Default | Description                                            |
| ------------------------------------------- | ------ | ------- | ------------------------------------------------------ |
| serviceAccount.create                       | bool   | `false` | Create service account for Hoppscotch                  |
| serviceAccount.name                         | string | `""`    | Service account name (auto-generated if not specified) |
| serviceAccount.annotations                  | object | `{}`    | Service account annotations                            |
| serviceAccount.automountServiceAccountToken | bool   | `true`  | Auto-mount service account token                       |
| rbac.create                                 | bool   | `false` | Create RBAC resources for Hoppscotch                   |
| rbac.rules                                  | list   | `[]`    | RBAC rules for Hoppscotch                              |

### Database Parameters

| Key                                             | Type   | Default                             | Description                                                           |
| ----------------------------------------------- | ------ | ----------------------------------- | --------------------------------------------------------------------- |
| postgresql.enabled                              | bool   | `false`                             | Enable PostgreSQL subchart                                            |
| postgresql.image.repository                     | string | `"bitnamilegacy/postgresql"`        | PostgreSQL image repository                                           |
| postgresql.auth.enablePostgresUser              | bool   | `true`                              | Enable PostgreSQL default postgres user                               |
| postgresql.auth.username                        | string | `""`                                | PostgreSQL application username                                       |
| postgresql.auth.password                        | string | `""`                                | PostgreSQL application password                                       |
| postgresql.auth.database                        | string | `""`                                | PostgreSQL application database name                                  |
| postgresql.auth.existingSecret                  | string | `""`                                | Existing secret containing PostgreSQL credentials                     |
| postgresql.auth.secretKeys.userPasswordKey      | string | `""`                                | Key in existing secret containing username                            |
| postgresql.architecture                         | string | `"standalone"`                      | PostgreSQL architecture (standalone or replication)                   |
| postgresql.primary.resourcesPreset              | string | `"small"`                           | PostgreSQL primary resource preset                                    |
| postgresql.primary.resources                    | object | `{}`                                | PostgreSQL primary resource limits/requests                           |
| postgresql.volumePermissions.image.repository   | string | `"bitnamilegacy/os-shell"`          | Volume Permissions image repository                                   |
| postgresql.metrics.image.repository             | string | `"bitnamilegacy/postgres-exporter"` | PostgreSQL Prometheus Exporter image repository                       |
| externalDatabase.host                           | string | `""`                                | External PostgreSQL host                                              |
| externalDatabase.port                           | int    | `5432`                              | External PostgreSQL port                                              |
| externalDatabase.user                           | string | `""`                                | External PostgreSQL username                                          |
| externalDatabase.database                       | string | `""`                                | External PostgreSQL database name                                     |
| externalDatabase.password                       | string | `""`                                | External PostgreSQL password                                          |
| externalDatabase.sqlConnection                  | string | `""`                                | External PostgreSQL full connection string (overrides other settings) |
| externalDatabase.existingSecret                 | string | `""`                                | Existing secret containing external PostgreSQL credentials            |
| externalDatabase.existingSecretPasswordKey      | string | `""`                                | Key in existing secret containing password                            |
| externalDatabase.existingSecretSqlConnectionKey | string | `""`                                | Key in existing secret containing SQL connection string               |

### Redis Parameters

| Key                                      | Type   | Default                          | Description                                           |
| ---------------------------------------- | ------ | -------------------------------- | ----------------------------------------------------- |
| redis.enabled                            | bool   | `false`                          | Enable Redis subchart                                 |
| redis.image.repository                   | string | `"bitnamilegacy/redis"`          | Redis image repository                                |
| redis.auth.enabled                       | bool   | `true`                           | Enable Redis authentication                           |
| redis.auth.password                      | string | `""`                             | Redis password                                        |
| redis.auth.existingSecret                | string | `""`                             | Existing secret containing Redis credentials          |
| redis.auth.existingSecretPasswordKey     | string | `""`                             | Key in existing secret containing password            |
| redis.architecture                       | string | `"standalone"`                   | Redis architecture (standalone or replication)        |
| redis.master.resourcesPreset             | string | `"small"`                        | Redis master resource preset                          |
| redis.master.resources                   | object | `{}`                             | Redis master resource limits/requests                 |
| redis.sentinel.image.repository          | string | `"bitnamilegacy/redis-sentinel"` | Redis Sentinel image repository                       |
| redis.metrics.image.repository           | string | `"bitnamilegacy/redis-exporter"` | Redis Exporter image repository                       |
| redis.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"`       | Volume Permissions image repository                   |
| redis.kubectl.image.repository           | string | `"bitnamilegacy/kubectl"`        | Kubectl image repository                              |
| redis.sysctl.image.repository            | string | `"bitnamilegacy/os-shell"`       | Sysctl image repository                               |
| externalRedis.host                       | string | `""`                             | External Redis host                                   |
| externalRedis.port                       | int    | `6379`                           | External Redis port                                   |
| externalRedis.password                   | string | `""`                             | External Redis password                               |
| externalRedis.existingSecret             | string | `""`                             | Existing secret containing external Redis credentials |
| externalRedis.existingSecretPasswordKey  | string | `""`                             | Key in existing secret containing password            |

### ClickHouse Parameters

| Key                                                                 | Type   | Default                             | Description                                                |
| ------------------------------------------------------------------- | ------ | ----------------------------------- | ---------------------------------------------------------- |
| clickhouse.enabled                                                  | bool   | `false`                             | Enable ClickHouse subchart                                 |
| clickhouse.defaultInitContainers.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"`          | Volume Permissions image repository                        |
| clickhouse.image.repository                                         | string | `"bitnamilegacy/clickhouse"`        | ClickHouse image repository                                |
| clickhouse.auth.username                                            | string | `""`                                | ClickHouse username                                        |
| clickhouse.auth.password                                            | string | `""`                                | ClickHouse password                                        |
| clickhouse.auth.existingSecret                                      | string | `""`                                | Existing secret containing ClickHouse credentials          |
| clickhouse.auth.existingSecretKey                                   | string | `""`                                | Key in existing secret containing password                 |
| clickhouse.resourcesPreset                                          | string | `"small"`                           | ClickHouse resource preset                                 |
| clickhouse.resources                                                | object | `{}`                                | ClickHouse resource limits/requests                        |
| clickhouse.keeper.image.repository                                  | string | `"bitnamilegacy/clickhouse-keeper"` | ClickHouse Keeper image repository                         |
| externalClickhouse.host                                             | string | `""`                                | External ClickHouse host                                   |
| externalClickhouse.port                                             | int    | `8123`                              | External ClickHouse port                                   |
| externalClickhouse.user                                             | string | `""`                                | External ClickHouse username                               |
| externalClickhouse.password                                         | string | `""`                                | External ClickHouse password                               |
| externalClickhouse.existingSecret                                   | string | `""`                                | Existing secret containing external ClickHouse credentials |
| externalClickhouse.existingSecretPasswordKey                        | string | `""`                                | Key in existing secret containing password                 |

<!-- markdownlint-enable MD013 MD034 -->
