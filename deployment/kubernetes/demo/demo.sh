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

GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o jsonpath={.items[0].status.hostIP}):$(kubectl get svc istio-ingress -n istio-system -o jsonpath={.spec.ports[0].nodePort})

echo "Istio Ingress URL: $GATEWAY_URL"
read -s

desc "Now we have our monolith running"
desc "Let's start to break up the monolith by removing the UI"
desc "Let's deploy a new UI"

run "kubectl apply -f $(relative ../core/frontend/tm-ui-svc.yml)"
run "kubectl apply -f $(relative ../core/frontend/talk-to-monolith/tm-ui-deployment.yml)"

desc "This is a dark release. We can try to proxy and try hit it"
read -s

desc "Now let's enable the traffic through the new UI"
run "kubectl replace -f $(relative ../core/frontend/ticket-monster-ingress.yml)"
read -s

desc "Let's use Istio ingress control to make sure that all traffic goes to the UI that calls only the MONOLITH"
read -s
desc "first, let's see what the route rule looks like"
run "cat $(relative ../istio/route-rules/route-tm-v1.yaml)"

desc "let's apply the rule"
run "istioctl create -f $(relative ../istio/route-rules/route-tm-v1.yaml)"





desc "So this is fine. Let's now deploy a new version of our monolith without the UI"

run "kubectl apply -f $(relative ../core/backend/backend-svc.yml)"
run "kubectl apply -f $(relative ../core/backend/v1/backend-v1-deployment.yml)"

desc "Now we have a new deployment but no traffic going through it."
desc "The new deployment is also connected to the monolith's database"

desc "Let's deploy a new version of the UI that connects directly to the backend"
read -s
run "kubectl apply -f $(relative ../core/frontend/talk-to-backend/tm-ui-deployment.yml)"

desc "No traffic should be going through this new UI deployment that talks to the backend"
desc "Let's set up a rule that allows us to dark launch this new version"
read -s

run "cat $(relative ../istio/route-rules/route-tm-v2-dark-launch.yaml)"
run "istioctl create -f $(relative ../istio/route-rules/route-tm-v2-dark-launch.yaml)"
desc "go check this dark deployment works as expected"
read -s

desc "Now let's let all traffic go to v2"
run "istioctl create -f $(relative ../istio/route-rules/route-tm-v2.yaml)"


desc "Now we have all traffic going through the split out UI and the backend"
desc "Now let's deploy the orders service again in a dark launch"
read -s

run "kubectl apply -f $(relative ../core/orders/orders-mysql-configmap.yml)"
run "kubectl apply -f $(relative ../core/orders/mysql-svc.yml)"
run "kubectl apply -f $(relative ../core/orders/mysql-deployment.yml)"

desc "Now let's deploy the service"
run "kubectl apply -f $(relative ../core/orders/orders-service-svc.yml)"
run "kubectl apply -f $(relative ../core/orders/orders-service-deployment.yml)"

desc "Now we can go smoke test this new service. Note it connects to the monolith/backend database"

# TODO: now we want the backend to call into the orders service




