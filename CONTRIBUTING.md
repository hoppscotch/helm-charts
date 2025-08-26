# Contributing to Hoppscotch Charts

Thank you for your interest in contributing to Hoppscotch Charts! This document provides guidelines and instructions for
contributing to the project.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to
uphold this code. Please report unacceptable behavior to the project maintainers.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include
as many details as possible:

- Use a clear and descriptive title
- Describe the exact steps to reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed and what behavior you expected to see
- Include screenshots if applicable
- Include your environment details

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the proposed functionality
- Include specific examples to demonstrate the proposal
- Explain why this enhancement would be useful

### Pull Requests

1. Fork the repository
2. Create a new branch from `main`
3. Make your changes
4. Add or update tests as needed
5. Update documentation as needed
6. Submit your pull request

#### Pull Request Process

1. Follow the existing code style and conventions
2. Update relevant documentation
3. Link any relevant issues
4. Request review from maintainers

## Development Setup

1. Install required tools:

   - Kubernetes cluster (local or cloud)
   - Helm 3.x
   - kubectl
   - Git

2. Clone the repository:

   ```bash
   git clone https://github.com/hoppscotch/helm-charts.git
   cd helm-charts
   ```

3. Create a branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

## Testing

- Test deployments in a local environment
- Ensure backwards compatibility

## Documentation

- Update relevant README files
- Add comments to complex code sections
- Update chart documentation
- Include examples when appropriate

## Commit Messages

- Use [Conventional Commits](https://www.conventionalcommits.org/). See commit scopes and types below.
- Be concise and descriptive Commit messages should be 50 characters or less.
- Use the imperative mood. Commit messages should follow this rule: if applied, this commit will `commit message`.
- Write for inclusion in the CHANGELOG. Commit messages should be written with the CHANGELOG in mind.
- Squash commits so they represent a single logical change. A new feature or bug fix should be a single commit.

The following commit scopes are recognized:

| Scope        | Title                 | Description                                |
| ------------ | --------------------- | ------------------------------------------ |
| `hoppscotch` | Hoppscotch            | Changes to the Hoppscotch chart            |
| `shc`        | Hoppscotch Community  | Changes to the Hoppscotch Community chart  |
| `she`        | Hoppscotch Enterprise | Changes to the Hoppscotch Enterprise chart |

The following commit types are recognized:

| Type       | Title       | Description                                                   |
| ---------- | ----------- | ------------------------------------------------------------- |
| `feat`     | Features    | A new feature for the user                                    |
| `fix`      | Bug Fix     | A bug fix                                                     |
| `docs`     | Docs        | Documentation only changes                                    |
| `style`    | Styles      | Changes that do not affect the meaning of the code            |
| `refactor` | Refactor    | A code change that neither fixes a bug nor adds a feature     |
| `perf`     | Performance | A code change that improves performance                       |
| `test`     | Tests       | Adding missing tests or correcting existing tests             |
| `build`    | Builds      | Changes that affect the build system or external dependencies |
| `ci`       | CI          | Changes to CI configuration files and scripts                 |
| `chore`    | Chores      | Other changes that don't modify src or test files             |
| `revert`   | Reverts     | Reverts a previous commit                                     |

## Community

- Join our Discord server
- Participate in GitHub Discussions
- Follow our blog for updates
- Attend community meetings

Thank you for contributing to Hoppscotch Charts!
