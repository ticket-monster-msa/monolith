Start up a database:

```
docker run -d  --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_PASSWORD=monster -e MYSQL_USER=ticket -e MYSQL_DATABASE=ticketmonster mysql:5.7
```

Connect to it via client:

```
docker run -it --link some-mysql:mysql --rm mysql:5.7 sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uticket -pmonster ticketmonster'
```

  
Login locally/natively
If you port forward the mysql ports to the docker container, you can run a mysql client locally:


```
mysql ticketmonster -h127.0.0.1 -uticket -pmonster 
```

You will need to set up the databases:

```
mysql ticketmonster -h127.0.0.1 -uticket -pmonster < ./scripts/grants.sql
mysql ticketmonster -h127.0.0.1 -uticket -pmonster < ./scripts/orders.sql
mysql ticketmonster -h127.0.0.1 -uticket -pmonster < ./scripts/ticketmonster.sql
```

An simple script to port forward minikube:

```
#!/bin/sh

port=${1:=3306}
minikube ssh -- -vnNTL *:$port:$(minikube ip):$port
```
