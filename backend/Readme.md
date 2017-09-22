This `backend` module contains the monolith Ticket Monster service **without** the UI. Use an external UI to connect pu to the REST API that this service exposes.


## How to build

Build the source code to connect to a MySQL database. Note the, default url that will be used is `mysql-backend:3306`

```
mvn clean install -Pmysql,kubernetes
```

To build the docker image associated with this:

```
mvn clean install -Pmysql,kubernetes fabric8:build
```

This will create a docker image named `ceposta/backend-mysql:latest`. This image is the same image that should be on Docker Hub: [https://hub.docker.com/r/ceposta/backend-mysql/](https://hub.docker.com/r/ceposta/backend-mysql/) 

This is the same image used in the deployment scripts.

If you want the `backend` service before we added scientist/FF impl, checkout this SHA: a07942b