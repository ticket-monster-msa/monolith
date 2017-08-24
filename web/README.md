## Ticket Monster UI

This proxy helps us keep friendly URLs even when there are composite UIs or composite microservice REST apis
It also helps us avoid tripping the browser Same Origin policy

Build the docker container:

> docker build -t ticketmonster/ui:1.0 .

Run in kubernetes

> kubectl run tm-ui --image=ticketmonster/ui:1.0 --port=80

Let's create the kubernetes service:

> kubectl apply -f tm-ui-svc.yml

When it comes time to include this UI service in the routing between services, you may want to inject it with the istio side proxy:

> kubectl replace -f <(kubectl get deploy tm-ui -o yaml | istioctl kube-inject -f -)
