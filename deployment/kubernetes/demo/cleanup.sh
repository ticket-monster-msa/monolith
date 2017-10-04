#!/usr/bin/env bash

# Monolith
kubectl delete svc/ticket-monster
kubectl delete svc/mysql-backend
kubectl delete deploy/ticket-monster
kubectl delete deploy/mysql-backend

# Backend
kubectl delete svc/backend
kubectl delete deploy/backend-v1
kubectl delete deploy/backend-v2

# UI
kubectl delete svc/tm-ui
kubectl delete deploy/tm-ui-v1
kubectl delete deploy/tm-ui-v2

# Orders Service
kubectl delete svc/orders-service
kubectl delete deploy/orders-service
kubectl delete svc/mysql-orders
kubectl delete deploy/mysql-orders
kubectl delete cm/orders-mysql-config



# Ingress
kubectl delete ingress/tm-gateway

# Delete istio routes
istioctl delete routerules $(istioctl get routerules | awk '{print $1}')