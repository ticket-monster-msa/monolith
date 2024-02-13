# Monolith TicketMonster

This is the monolith version of the TicketMonster app from the [tutorial on developers.redhat.com](https://developers.redhat.com/ticket-monster/).


This project illustrates the following concepts:

* App running in WildFly 10.x (EE 7)
* Packaging as a Docker image using [fabric8-maven-plugin](https://maven.fabric8.io)
* Connecting to a separate instance of `mysql` database
* Arquillian integration tests (embedded/remote)
* Deploying to Kubernetes with [fabric8-maven-plugin](https://maven.fabric8.io)


## Running TicketMonster

From the command line, you can run the application simply in a WildFly 10.x application server as simple as this:

```
mvn clean package wildfly:run
```

This builds the application with an embedded database and bootstraps an embedded application server and deploys the service available at [http://localhost:8080/ticket-monster](http://localhost:8080/ticket-monster). Give it a try to make sure everything comes up correctly.


### Running with docker:

If you're attached to a `docker` daemon:

```
docker run -it -p 8080:8080 ceposta/ticket-monster-monolith:latest
```

### Running on kubernetes

If you're connected to a Kubernetes instance, you can do a complete docker build and run of the application with the fabric8 maven plugin like this:

```
mvn clean package -Pdefault,kubernetes fabric8:run
```

## For developers: Building TicketMonster

TicketMonster can be built from Maven, by running the following Maven command:

```
mvn clean package
```
	
### Building TicketMonster with integration tests
	
If you want to run the Arquillian tests as part of the build, you can enable one of the two available Arquillian profiles.

For running the tests in an _already running_ application server instance, use the `arq-wildfly-remote` profile.

```
mvn clean package -Parq-wildfly-remote
```

If you want the test runner to _start_ an application server instance, use the `arq-wildfly-managed` profile. You must set up the `JBOSS_HOME` property to point to the server location, or update the `src/main/test/resources/arquillian.xml` file.

```
mvn clean package -Parq-wildfly-managed
```
	
### Building TicketMonster with MySQL 

If you want to build the WAR with support for MySQL database, build with the following profiles:

```
mvn clean package -Pmysql,default
```
       
Note, we explicitly enable the `mysql` profile and also the `default` profile. We keep the default profile around to skip integration tests. Leave it off to run them.    
	
### Building TicketMonster with MySQL and Kubernetes

First you should deploy a `mysql` instance. Take a [look at a Kubernetes deployment for mysql from here](../deployment/kubernetes/core/monolith/).

Deploy the `mysql` kubernetes service:

```
kubectl apply -f deployment/kubernetes/core/monolith/mysql-svc.yml
```

Next, deploy the `mysql` deployment:

```
kubectl apply -f deployment/kubernetes/core/monolith/mysql-deployment.yml
```

Lastly, deploy the latest version of the monolith:

```
mvn clean package -Pdefault,kubernetes,mysql fabric8:deploy
```

To undeploy:

```
mvn -Pdefault,kubernetes,mysql fabric8:undeploy
```