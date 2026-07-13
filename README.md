<!-- markdownlint-disable first-line-h1 no-duplicate-heading no-inline-html -->
<div align="center">
  <h3>
    <b>
      Hoppscotch Charts
    </b>
  </h3>
  <b>
    Scalable Kubernetes Deployments for Hoppscotch
  </b>
  <p>

[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen?logo=github)](CODE_OF_CONDUCT.md)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fhoppscotch.io&logo=hoppscotch)](https://hoppscotch.io)
[![Tweet](https://img.shields.io/twitter/url?url=https%3A%2F%2Fhoppscotch.io%2F)](https://twitter.com/share?text=%F0%9F%91%BD%20Hoppscotch%20%E2%80%A2%20Open%20source%20API%20development%20ecosystem%20-%20Helps%20you%20create%20requests%20faster,%20saving%20precious%20time%20on%20development.&url=https://hoppscotch.io&hashtags=hoppscotch&via=hoppscotch_io)

  </p>
  <p>
    <sub>
      Built with ❤︎ by
      <a href="https://github.com/hoppscotch/helm-charts/graphs/contributors">
        contributors
      </a>
    </sub>
  </p>
</div>

#### **Support**

[![Chat on Discord](https://img.shields.io/badge/chat-Discord-7289DA?logo=discord)](https://hoppscotch.io/discord)
[![Chat on Telegram](https://img.shields.io/badge/chat-Telegram-2CA5E0?logo=telegram)](https://hoppscotch.io/telegram)

### **Features**

❤️ **Enterprise Ready:** Built for large-scale deployments with security in mind.

⚡️ **High Performance:** Optimized for speed and resource efficiency.

🔒 **Security First:** Built-in security features and compliance controls.

🌐 **Multi-Cloud:** Deploy anywhere with our cloud-agnostic architecture.

🚀 **Scalable:** Automatically scales based on your workload.

🔄 **High Availability:** Built-in redundancy and failover capabilities.

### **Available Charts**

| Chart | Description |
| ----- | ----------- |
| [`hoppscotch`](charts/hoppscotch) | **Recommended.** Unified chart (Community + Enterprise, AIO or distributed) — used by the guides below |
| [`shc`](charts/shc) | Community edition chart — maintained for backward compatibility, superseded by [`hoppscotch`](charts/hoppscotch) |
| [`she`](charts/she) | Enterprise edition chart — maintained for backward compatibility, superseded by [`hoppscotch`](charts/hoppscotch) |

> For deployment modes, configuration and the full parameters list, see the **[chart README](charts/hoppscotch/README.md)** — it is the authoritative install guide. The guides below are provider-specific quick starts.
>
> Migrating an existing `shc` or `she` deployment? Follow the **[migration guide](MIGRATION.md)**.

### **Installation Guides**

<details>
<summary><b>Digital Ocean Installation</b></summary>

**Prerequisites**

- Access to a DOKS cluster (kubeconfig via `doctl` or the console)
- Cluster permissions to create the chart's resources (cluster-admin only if you also install an ingress controller)
- kubectl and Helm 3.x
- doctl (to fetch the kubeconfig)

**Quick Install**

```bash
# Configure access
export KUBECONFIG=path/to/k8s-config.yaml

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml

# Add chart repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Deploy application (edition is selected in your values file)
helm install [RELEASE_NAME] hoppscotch/hoppscotch -f [path-to-values-file]
```

> Configuration (deployment mode, database, ingress/TLS, etc.) is set in your values file — see the [chart README](charts/hoppscotch/README.md) for the full guide and all parameters.
>
> - **Load balancer / ingress:** use NGINX ingress (`aio.ingress.*`) or a DigitalOcean LB via `aio.service.type: LoadBalancer` with `service.beta.kubernetes.io/do-loadbalancer-*` under `aio.service.annotations`. In `distributed` mode the same keys exist per component.

</details>

<details>
<summary><b>GCP Installation</b></summary>

**Prerequisites**

- Access to a GKE cluster (kubeconfig via `gcloud`)
- Cluster permissions to create the chart's resources (cluster-admin only if you also install an ingress controller)
- kubectl and Helm 3.x
- gcloud CLI (to fetch the kubeconfig)

**Quick Install**

```bash
# Configure cluster access
gcloud container clusters get-credentials cluster-name --zone zone --project project-id

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Add chart repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Deploy application (edition is selected in your values file)
helm install [RELEASE_NAME] hoppscotch/hoppscotch -f [path-to-values-file]
```

> Configuration (deployment mode, database, ingress/TLS, etc.) is set in your values file — see the [chart README](charts/hoppscotch/README.md) for the full guide and all parameters.
>
> - **Load balancer / ingress:** use the GKE ingress (`aio.ingress.ingressClassName: gce` + `aio.ingress.annotations`) or a Google Cloud LB via `aio.service.type: LoadBalancer` with `networking.gke.io/*` under `aio.service.annotations`. In `distributed` mode the same keys exist per component.

</details>

<details>
<summary><b>AWS EKS Installation</b></summary>

**Prerequisites**

- Access to an EKS cluster (kubeconfig via `aws eks update-kubeconfig`)
- Cluster permissions to create the chart's resources (cluster-admin only if you also install an ingress/ALB controller)
- kubectl and Helm 3.x
- AWS CLI (to fetch the kubeconfig)

**Quick Install**

```bash
# Configure cluster access
aws eks update-kubeconfig --name cluster-name --region region

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

# Add chart repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Deploy application (edition is selected in your values file)
helm install [RELEASE_NAME] hoppscotch/hoppscotch -f [path-to-values-file]
```

> Configuration (deployment mode, database, ingress/TLS, etc.) is set in your values file — see the [chart README](charts/hoppscotch/README.md) for the full guide and all parameters.
>
> - **Load balancer / ingress:** use an ALB (`aio.ingress.ingressClassName: alb` + `alb.ingress.kubernetes.io/*`, AWS Load Balancer Controller required) or an NLB via `aio.service.type: LoadBalancer` with `service.beta.kubernetes.io/aws-load-balancer-*` under `aio.service.annotations`. In `distributed` mode the same keys exist per component.

</details>

<details>
<summary><b>Azure AKS Installation</b></summary>

**Prerequisites**

- Access to an AKS cluster (kubeconfig via `az aks get-credentials`)
- Cluster permissions to create the chart's resources (cluster-admin only if you also install an ingress controller)
- kubectl and Helm 3.x
- Azure CLI (to fetch the kubeconfig)

**Quick Install**

```bash
# Configure cluster access
az aks get-credentials --resource-group resource-group --name cluster-name

# (Optional) Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Add chart repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Deploy application (edition is selected in your values file)
helm install [RELEASE_NAME] hoppscotch/hoppscotch -f [path-to-values-file]
```

> Configuration (deployment mode, database, ingress/TLS, etc.) is set in your values file — see the [chart README](charts/hoppscotch/README.md) for the full guide and all parameters.
>
> - **Load balancer / ingress:** use Application Gateway ingress (`aio.ingress.ingressClassName: azure-application-gateway` + `appgw.ingress.kubernetes.io/*`) or an Azure LB via `aio.service.type: LoadBalancer` with `service.beta.kubernetes.io/azure-load-balancer-*` under `aio.service.annotations`. In `distributed` mode the same keys exist per component.

</details>

<details>
<summary><b>OpenShift Installation</b></summary>

**Prerequisites**

- OpenShift 4.x cluster (works on the default `restricted-v2` SCC — no cluster-admin required)
- oc CLI logged in to your cluster
- Helm 3.x installed

**Quick Install**

```bash
# Add chart repository
helm repo add hoppscotch https://hoppscotch.github.io/helm-charts

# Deploy on OpenShift (adapts securityContext for restricted-v2 and exposes a Route)
helm upgrade --install [RELEASE_NAME] hoppscotch/hoppscotch \
  --namespace hoppscotch --create-namespace \
  -f [path-to-values-file]
```

On OpenShift, enable `global.compatibility.openshift.adaptSecurityContext` and expose the app with a Route
instead of an Ingress. See the chart's [Deploying on OpenShift](charts/hoppscotch/README.md#deploying-on-openshift)
guide for the full walkthrough — `restricted-v2` requirements, `HOPP_ALTERNATE_PORT`, and both `aio` and
`distributed` modes.

</details>

## **About Helm Charts**

Our application uses Helm for package management in Kubernetes. Helm Charts help you:

- 📦 Define, install, and upgrade Kubernetes applications
- 🔄 Share applications with others
- 🔧 Manage complex deployments with simple commands
- ⏪ Roll back to previous versions when needed

## **Contributing**

Please contribute using [GitHub Flow](https://guides.github.com/introduction/flow). Create a branch, add commits, and
[open a pull request](https://github.com/hoppscotch/helm-charts/compare).

Please read [`CONTRIBUTING`](CONTRIBUTING.md) for details on our [`CODE OF CONDUCT`](CODE_OF_CONDUCT.md), and the
process for submitting pull requests to us.

## **Continuous Integration**

We use [GitHub Actions](https://github.com/features/actions) for continuous integration.

## **Authors**

This project owes its existence to the collective efforts of all those who contribute —
[contribute now](CONTRIBUTING.md).

<div align="center">
  <a href="https://github.com/hoppscotch/helm-charts/graphs/contributors">
    <img src="https://opencollective.com/hoppscotch/contributors.svg?width=840&button=false"
      alt="Contributors"
      width="100%" />
  </a>
</div>

## **License**

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT) — see the [`LICENSE`](LICENSE)
file for details.
