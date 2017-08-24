This folder has some helper files for deploying on vanilla k8s with istio.

Note, for the scripts to work, we need to have built the project with the fabric8:resource goal because we will deploy resources from the `$ROOT/target` folder

> kubectl apply -f web/tm-ui-svc.yml
> $ROOT/kubernetes/istio/deploy.sh
> kubectl run tm-ui --image=ticketmonster/ui:1.0 --port=80
> kubectl replace -f <(kubectl get deploy tm-ui -o yaml | istioctl kube-inject -f -)
> ./get-urls.sh 
 