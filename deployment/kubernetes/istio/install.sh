#!/usr/bin/env bash
curl -L https://git.io/getLatestIstio | sh -
ISTIO=`ls | grep istio`
export PATH="$PATH:~/$ISTIO/bin"
cd $ISTIO
kubectl apply -f install/kubernetes/istio.yaml

kubectl create -f install/kubernetes/addons/prometheus.yaml
kubectl create -f install/kubernetes/addons/grafana.yaml
kubectl create -f install/kubernetes/addons/servicegraph.yaml
kubectl create -f install/kubernetes/addons/zipkin.yaml