## Ticket Monster UI

This proxy helps us keep friendly URLs even when there are composite UIs or composite microservice REST apis
It also helps us avoid tripping the browser Same Origin policy

Build the docker container:

> docker build -t ceposta/tm-ui:backend .

Run in kubernetes

> kubectl run tm-ui --image=ceposta/tm-ui:1.0 --port=80

Or using the resource file:

> kubectl apply -f ../deployment/kubernetes/backend/tm-ui-deployment.yml

Let's create the kubernetes service:

> kubectl apply -f ../deployment/kubernetes/backend/tm-ui-svc.yml

When it comes time to include this UI service in the routing between services, you may want to inject it with the istio side proxy:

> kubectl replace -f <(kubectl get deploy tm-ui -o yaml | istioctl kube-inject -f -)

## Ticket Monster Monolith 

If you want to build the version the UI that talks directly to the monolith (instead of the backend which is the REST API without the UI), then checkout SHA 0c570d1 and build this docker image. Right now it points to the `backend` service. You can see the tags for the `tm-ui` here: [https://hub.docker.com/r/ceposta/tm-ui/tags/](https://hub.docker.com/r/ceposta/tm-ui/tags/)
