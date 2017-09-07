#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

RUN_CMD="bash -c "

if [ "$1" == "--interactive" ]; then
    echo "Step by step instructions!"
    RUN_CMD="run "
fi

echo "deploying backend..."

$RUN_CMD "kubectl apply -f $(relative ../core/backend/mysql-deployment.yml)"
$RUN_CMD "kubectl apply -f $(relative ../core/backend/mysql-svc.yml)"

while [ "$(kubectl get pod | grep mysql-backend | awk '{ print $2}')" != "1/1" ];
do
  sleep 1;
done

$RUN_CMD "kubectl apply -f $(relative ../core/backend/ticket-monster-deployment.yml)"
$RUN_CMD "kubectl apply -f $(relative ../core/backend/ticket-monster-svc.yml)"

echo "deploying frontend"

$RUN_CMD "kubectl apply -f $(relative ../core/frontend/tm-ui-deployment.yml)"
$RUN_CMD "kubectl apply -f $(relative ../core/frontend/tm-ui-svc.yml)"

echo "deploying istio ingress for frontend"

$RUN_CMD "kubectl apply -f $(relative ../core/frontend/ticket-monster-ingress.yml)"
