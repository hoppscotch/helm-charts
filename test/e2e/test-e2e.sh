#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CLUSTER_CREATED=false
CLUSTER_NAME=$(mktemp -u "chart-testing-XXXXXXXXXX" | tr "[:upper:]" "[:lower:]")
CT_VERSION=v3.14.0
K8S_VERSION=v1.35.0
ROOT_DIR="$(git rev-parse --show-toplevel)"

RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

cleanup() {
  local exit_code=$?
  log_info "Cleaning up resources"

  log_info "Removing ct container"
  if docker ps --filter="name=ct" --filter="status=running" | grep -q ct; then
    docker kill ct >/dev/null 2>&1
  else
    log_warn "ct container not running"
  fi

  if [ "${CLUSTER_CREATED}" = true ]; then
    log_info "Removing kind cluster ${CLUSTER_NAME}"
    if kind get clusters | grep -q "${CLUSTER_NAME}"; then
      kind delete cluster --name="${CLUSTER_NAME}"
    else
      log_warn "kind cluster ${CLUSTER_NAME} not found"
    fi
  fi

  exit $exit_code
}

create_kind_cluster() {
  log_info "Creating kind cluster ${CLUSTER_NAME}"

  if ! command -v kind &>/dev/null; then
    log_error "kind is not installed"
    exit 1
  fi

  if kind get clusters | grep -q "${CLUSTER_NAME}"; then
    log_error "kind cluster ${CLUSTER_NAME} already exists"
    exit 1
  fi

  kind create cluster --name="${CLUSTER_NAME}" --config="${ROOT_DIR}/test/e2e/kind.yaml" \
    --image="kindest/node:${K8S_VERSION}" --wait=60s

  log_info "Installing ingress-nginx"
  kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
  CLUSTER_CREATED=true

  log_info "Copying kubeconfig to ct container"
  docker_exec mkdir /root/.kube
  docker cp ~/.kube/config ct:/root/.kube/config

  log_info "Waiting for cluster to be ready"
  timeout=60s
  while ! kubectl wait --namespace=ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=${timeout}; do
    log_error "Cluster did not become ready within ${timeout}"
    exit 1
  done

  log_info "Cluster ready!"
  echo
}

docker_exec() {
  docker exec --interactive ct "$@"
}

install_charts() {
  log_info "Installing charts"
  docker_exec ct install "$@"
}

log_error() { echo -e "${RED}Error:${RESET} $1" >&2; }
log_info() { echo -e "$1"; }
log_warn() { echo -e "${YELLOW}Warning:${RESET} $1" >&2; }

parse_args() {
  # Ignore unknown arguments, will be handled by ct
  for arg in "$@"; do
    case $arg in
    -h | --help)
      show_help
      exit 0
      ;;
    esac
  done
}

run_ct_container() {
  log_info "Running ct container"

  if ! command -v docker &>/dev/null; then
    log_error "Docker is not installed"
    exit 1
  fi

  docker run --rm --interactive --detach --network host --name ct \
    --volume "${ROOT_DIR}:/workdir" \
    --workdir /workdir \
    "quay.io/helmpack/chart-testing:${CT_VERSION}" \
    cat

  # If ct.yaml exists in script directory, copy it to the container
  if [ -f "${ROOT_DIR}/ct.yaml" ]; then
    log_info "Copying ct.yaml to ct container"
    docker cp "${ROOT_DIR}/ct.yaml" ct:/etc/ct/ct.yaml
  else
    log_info "ct.yaml not found, using default configuration"
  fi
  echo
}

show_help() {
  echo "Usage: $(basename "$0") [options]"
  echo ""
  echo "End-to-end testing script for Helm charts using chart-testing and kind. All unknown arguments will be passed to chart-testing."
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message and exit"
  echo ""
}

main() {
  parse_args "$@"

  run_ct_container
  trap cleanup EXIT

  create_kind_cluster
  install_charts "$@"

  log_info "All tests completed successfully!"
}

main "$@"
