# Agent guidelines

This repository contains [Helm charts](https://helm.sh/) for [Hoppscotch](https://github.com/hoppscotch/hoppscotch), a
lightweight, web-based API development suite. Follow the guidelines below when working in this repository with an agent.

## Chart structure and organization

### Directory structure

- Place templates in the `templates/` directory and use subdirectories to organize by container or resource type. For
  example, `templates/aio/` includes AIO container templates and `templates/config/` includes configmap and secret
  templates.
- Place unit tests in the `tests/` directory
- Place integration tests in the `templates/tests/` directory
- Place end-to-end tests in the `ci/` directory
- Place commonly shared templates in `_helpers.tpl` and resource-specific shared templates `_<resource-type>.tpl` files
- Use subdirectories to organize templates by either container or resource group (e.g., `templates/<container-name>/` or
  `templates/<resource-group>/`)

### Naming conventions

- Use lowercase, hyphenated names for chart directories and values files
- Use camelCase for template definitions and variables
- Name template files after the resources they create

## Development environment

- Use `make install-deps` to install dependencies

## Build and test commands

- Run `make fmt` and `make fmt-fix` to check and fix file formatting issues
- Run `make fmt-<file-type>` and `make fmt-<file-type>-fix` to check and fix file formatting issues for a specific file
  type
- Run `make lint` to check for linting issues
- Run `make lint-<file-type>` to check for linting issues for a specific file type
- Run `make test` to run unit, integration, and end-to-end tests
- Run `make test-<test-type>` to run specific test types
- Run `TEST_UNIT_FILES=<test-file-glob-paths> make test-unit` to run specific unit tests

## Code style and conventions

- Use [Helm Chart Best Practices Guide](https://helm.sh/docs/chart_best_practices/) for chart design best practices
- Use popular Helm charts such as [Bitnami charts](https://github.com/bitnami/charts) and
  [Grafana charts](https://github.com/grafana/helm-charts) for common design patterns

## Testing guidelines

### Unit testing

- Use [helm unittest](https://github.com/helm-unittest/helm-unittest) for unit tests
- Add unit tests for major, minor, and patch changes
- Do not write unit tests that just check the existence of a value. Instead, assert the correctness of the value using
  helm unittest [assertions](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md#assertion) such as
  `equal` for static values or `matchRegex` for dynamic values.
- Use helm unittest [Kubernetes provider](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md) to unit
  test existing resource lookup logic

### Integration testing

- Use [helm chart tests](https://helm.sh/docs/topics/chart_tests/) for integration tests
- Add integration tests to check readiness probes for each container

### End-to-end testing

- Use [chart-testing](https://github.com/helm/chart-testing) for end-to-end tests
- Add end-to-end tests for major changes

## Security considerations

- Prefer secure defaults that can be disabled if needed
- Use [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to restrict access to resources
- Store sensitive information in [secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and reference them
  using environment variables

## Commit guidelines

- Use `make pre-commit` to run pre-commit checks and resolve all issues before committing
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages
- Type should be one of the following:
  - **build**: Changes that affect the build system or external dependencies
  - **chore**: Other changes that don't modify src or test files
  - **ci**: Changes to CI configuration files and scripts
  - **docs**: Documentation only changes
  - **feat**: A new feature
  - **fix**: A bug fix
  - **perf**: A code change that improves performance
  - **refactor**: A code change that neither fixes a bug nor adds a feature
  - **style**: Changes that don't affect the meaning of the code
  - **test**: Adding missing tests or correcting existing tests
- Scope should be the name of the chart affected. The following is the list of supported scopes:
  - **hoppscotch**: Hoppscotch chart
  - **shc**: Hoppscotch community chart
  - **she**: Hoppscotch enterprise chart`
