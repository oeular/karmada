#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")/..

function usage() {
  echo "This script will remove karmada control plane from a cluster."
  echo "Usage: hack/undeploy-karmada.sh [KUBECONFIG] [CONTEXT_NAME]"
  echo "Example: hack/undeploy-karmada.sh ~/.kube/karmada.config karmada-host"
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

# check kube config file existence
if [[ ! -f "${1}" ]]; then
  echo -e "ERROR: failed to get kubernetes config file: '${1}', not existed.\n"
  usage
  exit 1
fi
HOST_CLUSTER_KUBECONFIG=$1

# check context existence
if ! kubectl config use-context "${2}" --kubeconfig="${HOST_CLUSTER_KUBECONFIG}" > /dev/null 2>&1;
then
  echo -e "ERROR: failed to use context: '${2}' not in ${HOST_CLUSTER_KUBECONFIG}. \n"
  usage
  exit 1
fi
HOST_CLUSTER_NAME=$2

# delete all keys and certificates
rm -fr "${HOME}/.karmada"

kubectl config use-context "${HOST_CLUSTER_NAME}" --kubeconfig="${HOST_CLUSTER_KUBECONFIG}"

# clear all in namespace karmada-system
kubectl delete ns karmada-system --kubeconfig="${HOST_CLUSTER_KUBECONFIG}"

# clear configs about karmada-apiserver in kubeconfig
kubectl config delete-cluster karmada-apiserver --kubeconfig="${HOST_CLUSTER_KUBECONFIG}"
kubectl config unset users.karmada-apiserver --kubeconfig="${HOST_CLUSTER_KUBECONFIG}"
kubectl config delete-context karmada-apiserver --kubeconfig="${HOST_CLUSTER_KUBECONFIG}"
