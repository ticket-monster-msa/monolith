#!/usr/bin/env bash


# deploy ticket-monster with kube-inject
kubectl apply -f <(istioctl kube-inject -f ../../target/classes/META-INF/fabric8/kubernetes/ticket-monster-deployment.yml)

# deploy the svc
kubectl apply -f ../../target/classes/META-INF/fabric8/kubernetes/ticket-monster-svc.yml

# deploy the ingress

kubectl apply -f ./istio-ingress/ticket-monster-ingress.yml

