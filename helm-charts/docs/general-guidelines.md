# General Guidelines for Hoppscotch Charts

This document provides general guidelines and best practices for using Hoppscotch Charts in your Kubernetes deployments.

## Overview

Hoppscotch Charts provides Helm charts for deploying Hoppscotch in Kubernetes environments. These charts are designed to be:

- Enterprise-ready for large-scale deployments
- Highly performant and resource-efficient
- Secure by default with built-in compliance controls
- Cloud-agnostic for flexible deployment options
- Automatically scalable based on workload
- Highly available with redundancy features

## Prerequisites

Before deploying Hoppscotch using these Helm charts, ensure you have:

1. Kubernetes cluster access
2. Helm 3.x installed
3. kubectl CLI tool
4. Appropriate cloud provider CLI tools (based on your deployment target)

## Chart Organization

The repository contains two main chart collections:

1. **SHC (Community Edition)**
   - Free and open-source version
   - Suitable for individual developers and small teams
   - Community-supported

2. **SHE (Enterprise Edition)**
   - Enhanced features for enterprise use
   - Additional security and compliance features
   - Professional support available

## Best Practices

### Security
- Always review the values.yaml file before deployment
- Use secret management solutions for sensitive data
- Implement network policies as needed
- Regular security audits and updates

### Performance
- Configure resource requests and limits appropriately
- Monitor resource utilization
- Use horizontal pod autoscaling when needed

### High Availability
- Deploy across multiple availability zones
- Configure appropriate replica counts
- Implement proper backup strategies

## Support

For support, you can:
- Join our [Discord community](https://hoppscotch.io/discord)
- Join our [Telegram group](https://hoppscotch.io/telegram)
- Participate in [GitHub Discussions](https://github.com/hoppscotch/hoppscotch/discussions)

## Updates and Maintenance

- Regular updates are provided through our GitHub repository
- Follow semantic versioning for releases

For specific implementation details, please refer to the SHC (Community) or SHE (Enterprise) usage guides.