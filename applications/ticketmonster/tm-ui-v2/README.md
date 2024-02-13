## Ticket Monster UI

This proxy helps us keep friendly URLs even when there are composite UIs or composite microservice REST apis
It also helps us avoid tripping the browser Same Origin policy. We use a simple HTTP server (apache) to serve the static content and then use the reverse proxy plugins to proxy REST calls to the appropriate microservice:

```
# proxy for the admin microserivce
ProxyPass "/rest" "http://backend:8080/rest"
ProxyPassReverse "/rest" "http://backend:8080/rest"
```


## Running in docker

The docker image for this project is `ceposta/tm-ui:backend`

## Developers:

Build the docker container:

> docker build -t ceposta/tm-ui:backend .

Run in kubernetes

> kubectl run tm-ui --image=ceposta/tm-ui:backend --port=80

Or using the resource files in the [deployment](../deployment/kubernetes/core/frontend/) folder.

