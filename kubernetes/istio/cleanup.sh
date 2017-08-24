#!/usr/bin/env bash

kubectl delete svc/ticket-monster
kubectl delete deploy/ticket-monster
kubectl delete ingress/gateway