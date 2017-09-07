#!/usr/bin/env bash

kubectl delete svc/ticket-monster
kubectl delete svc/tm-ui
kubectl delete svc/mysql-backend
kubectl delete deploy/ticket-monster
kubectl delete deploy/tm-ui
kubectl delete deploy/mysql-backend
kubectl delete ingress/tm-gateway