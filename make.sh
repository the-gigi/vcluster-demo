#!/usr/bin/env zsh

set -eu

HOST_CLUSTER=vcluster-host
HOST_CLUSTER_CTX="kind-${HOST_CLUSTER}"
VCLUSTERS=(vcluster-1 vcluster-2 vcluster-3)

# provision() creates the host clusters if needed and the 3 virtual clusters
function provision() {
  if ! [[ $(kubectl config get-contexts | rg " ${HOST_CLUSTER_CTX}") ]]; then
    echo --- creating a kind cluster...
    kind create cluster -n "${HOST_CLUSTER}"
  else
    kubectl config set-context "${HOST_CLUSTER_CTX}"
  fi

  if [[ $(kubectl config current-context) != "${HOST_CLUSTER_CTX}" ]]; then
    return 1
  fi

  echo --- preparing three virtual clusters: vcluster-demo-1 vcluster-demo-2 vcluster-demo-3
  for ((i = 1; i <= $#VCLUSTERS; i++)); do
    cluster=${VCLUSTERS[$i]}
    if ! [[ $(vcluster list | rg $cluster) ]]; then
      echo preparing virtual cluster $cluster...
      # calculate k8s minor version
      (( version = 22 + i))

      # create the virtual cluster
      vcluster create $cluster -n $cluster --kubernetes-version "1.${version}" --context "${HOST_CLUSTER_CTX}"
      vcluster disconnect
    fi
  done


  if [[ $(kubectl config current-context) != "${HOST_CLUSTER_CTX}" ]]; then
    echo kube context should be "${HOST_CLUSTER_CTX}"
    return 1
  fi
}

function deploy() {
  echo "deploying $IMAGE"

  echo --- deploying nginx
  for cluster in ${VCLUSTERS}[@]; do
    echo deploying leader-elector to $cluster cluster
    context="vcluster_${cluster}_${cluster}_${HOST_CLUSTER_CTX}"
    kubectl create deploy nginx --image nginx --context $context
  done
}

function check-logs() {
  for cluster in $VCLUSTERS[@]; do
    echo ---------------
    echo $cluster logs
    echo ---------------
    context="vcluster_${cluster}_${cluster}_${HOST_CLUSTER_CTX}"
    kubectl logs deploy/nginx | tail -n 5
    echo
  done
}

# Run the function that was passed as argument
$1
