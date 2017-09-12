Start up a database:

```
docker run -d  --name some-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_PASSWORD=monster -e MYSQL_USER=ticket -e MYSQL_DATABASE=ticketmonster mysql:5.7
```

Connect to it via client:

```
docker run -it --link some-mysql:mysql --rm mysql:5.7 sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uticket -pmonster ticketmonster'
```
  
