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

[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen?logo=github)](CODE_OF_CONDUCT.md) [![Website](https://img.shields.io/website?url=https%3A%2F%2Fhoppscotch.io&logo=hoppscotch)](https://hoppscotch.io) [![Tweet](https://img.shields.io/twitter/url?url=https%3A%2F%2Fhoppscotch.io%2F)](https://twitter.com/share?text=%F0%9F%91%BD%20Hoppscotch%20%E2%80%A2%20Open%20source%20API%20development%20ecosystem%20-%20Helps%20you%20create%20requests%20faster,%20saving%20precious%20time%20on%20development.&url=https://hoppscotch.io&hashtags=hoppscotch&via=hoppscotch_io)

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

[![Chat on Discord](https://img.shields.io/badge/chat-Discord-7289DA?logo=discord)](https://hoppscotch.io/discord) [![Chat on Telegram](https://img.shields.io/badge/chat-Telegram-2CA5E0?logo=telegram)](https://hoppscotch.io/telegram) [![Discuss on GitHub](https://img.shields.io/badge/discussions-GitHub-333333?logo=github)](https://github.com/hoppscotch/hoppscotch/discussions)

### **Features**

❤️ **Enterprise Ready:** Built for large-scale deployments with security in mind.

⚡️ **High Performance:** Optimized for speed and resource efficiency.

🔒 **Security First:** Built-in security features and compliance controls.

🌐 **Multi-Cloud:** Deploy anywhere with our cloud-agnostic architecture.

🚀 **Scalable:** Automatically scales based on your workload.

🔄 **High Availability:** Built-in redundancy and failover capabilities.

### **Installation Guides**

<details>
<summary><b>Digital Ocean Installation</b></summary>

## Prerequisites
- Digital Ocean account with administrative access
- kubectl CLI tool
- Helm 3.x installed
- doctl installed

## Quick Install
```bash
# Configure access
export KUBECONFIG=path/to/k8s-config.yaml

# Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/do/deploy.yaml

# Deploy application
helm install my-release ./helm-charts/app -f [path-to-values-file]
```

[View Detailed Digital Ocean Guide](./docs/installation/digitalocean.md)
</details>

<details>
<summary><b>GCP Installation</b></summary>

## Prerequisites
- Google Cloud account with GKE access
- gcloud CLI configured
- kubectl CLI tool
- Helm 3.x installed

## Quick Install
```bash
# Configure cluster access
gcloud container clusters get-credentials cluster-name --zone zone --project project-id

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Deploy application
helm install my-release ./helm-charts/app -f [path-to-values-file]
```

[View Detailed GCP Guide](./docs/installation/gcp.md)
</details>

## **About Helm Charts**

Our application uses Helm for package management in Kubernetes. Helm Charts help you:

- 📦 Define, install, and upgrade Kubernetes applications
- 🔄 Share applications with others
- 🔧 Manage complex deployments with simple commands
- ⏪ Roll back to previous versions when needed

## **Contributing**

Please contribute using [GitHub Flow](https://guides.github.com/introduction/flow). Create a branch, add commits, and [open a pull request](https://github.com/hoppscotch/helm-charts/compare).

Please read [`CONTRIBUTING`](CONTRIBUTING.md) for details on our [`CODE OF CONDUCT`](CODE_OF_CONDUCT.md), and the process for submitting pull requests to us.


## **Continuous Integration**

We use [GitHub Actions](https://github.com/features/actions) for continuous integration. Check out our [build workflows](https://github.com/hoppscotch/hoppscotch/actions).

## **Changelog**

See the [`CHANGELOG`](CHANGELOG.md) file for details.

## **Authors**

This project owes its existence to the collective efforts of all those who contribute — [contribute now](CONTRIBUTING.md).

<div align="center">
  <a href="https://github.com/hoppscotch/helm-charts/graphs/contributors">
    <img src="https://opencollective.com/hoppscotch/contributors.svg?width=840&button=false"
      alt="Contributors"
      width="100%" />
  </a>
</div>

## **License**

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT) — see the [`LICENSE`](LICENSE) file for details.