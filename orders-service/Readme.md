Run mysql database by following instructiosn in [the mysql docs](./docs/mysql.md)

Then build the project with mysql support:

```
mvn clean install -Pmysql
```

Or run with spring boot:

```
mvn -Pmysql spring-boot:run -Dspring.profiles.active=mysql 
```

```
curl -X POST -H "Content-Type: application/json" -d "{\"ticketRequests\":[{\"ticketPrice\":4,\"quantity\":3}],\"email\":\"foo@bar.coom\",\"performance\":1}" http://localhost:8080/rest/bookings
```