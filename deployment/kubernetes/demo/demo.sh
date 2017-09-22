#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh


desc "Deploy Monolith's Database"
run "kubectl apply -f $(relative ../core/monolith/mysql-svc.yml)"
run "kubectl apply -f $(relative ../core/monolith/mysql-deployment.yml)"

desc "Deploy monolith application"
run "kubectl apply -f $(relative ../core/monolith/ticket-monster-svc.yml)"
run "kubectl apply -f $(relative ../core/monolith/ticket-monster-deployment.yml)"

desc "Deploy an ingress point so we can see the application"
run "kubectl apply -f $(relative ../core/monolith/ticket-monster-ingress.yml)"

GATEWAY_URL=$(kubectl get po -l istio=ingress -o jsonpath={.items[0].status.hostIP}):$(kubectl get svc istio-ingress -o jsonpath={.spec.ports[0].nodePort})

echo "Istio Ingress URL: $GATEWAY_URL"
read -s

desc "Now we have our monolith running"
desc "Let's start to break up the monolith by removing the UI"
desc "Let's deploy a new UI"

run "kubectl apply -f $(relative ../core/frontend/talk-to-monolith/tm-ui-svc.yml)"
run "kubectl apply -f $(relative ../core/frontend/talk-to-monolith/tm-ui-deployment.yml)"

desc "This is a dark release. We can try to proxy and try hit it"
read -s

desc "Now let's enable the traffic through the new UI"
run "kubectl replace -f $(relative ../core/frontend/ticket-monster-ingress.yml)"



desc "So this is fine. Let's now deploy a new version of our monolith without the UI"

run "kubectl apply -f $(relative ../core/backend/backend-svc.yml)"
run "kubectl apply -f $(relative ../core/backend/backend-deployment.yml)"

desc "Now we have a new deployment but no traffic going through it."
desc "The new deployment is also connected to the monolith's database"

desc "Let's deploy a new version of the UI that connects directly to the backend"
read -s
run "kubectl apply -f $(relative ../core/frontend/talk-to-backend/tm-ui-deployment.yml)"

desc "Now let's scale down the v1 of the UI so all traffic goes to v2"
run "kubectl scale deploy/tm-ui-v1 --replicas=0"

desc "Now we have all traffic going through the split out UI and the backend"
desc "Now let's deploy the orders service in a dark launch"
read -s

run "kubectl apply -f $(relative ../core/orders/orders-mysql-configmap.yml)"
run "kubectl apply -f $(relative ../core/orders/mysql-svc.yml)"
run "kubectl apply -f $(relative ../core/orders/mysql-deployment.yml)"

desc "Now let's deploy the service"
run "kubectl apply -f $(relative ../core/orders/orders-service-svc.yml)"
run "kubectl apply -f $(relative ../core/orders/orders-service-deployment.yml)"

desc "Now we can go smoke test this new service. Note it connects to the monolith/backend database"

# TODO: now we want the backend to call into the orders service




