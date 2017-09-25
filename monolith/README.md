# TicketMonster - a JBoss example

TicketMonster is an online ticketing demo application that gets you started with JBoss technologies, and helps you learn and evaluate them.

Here are a few instructions for building and running it. You can learn more about the example from the [tutorial](http://www.jboss.org/ticket-monster).

## Updating the Performance dates

_NOTE: This step is optional. It is necessary only if you want to update the dates of the Performances in the `import.sql` script in an automated manner. Updating the performance dates ensure that they are always set to some timestamp in the future, and ensures that all performances are visible in the Monitor section of the TicketMonster application._

1. Run the `update_import_sql` Perl script. You'll need the `DateTime`, `DateTime::Format::Strptime` and `Tie::File` Perl modules. These are usually available by default in your Perl installation.
    
        $ perl update_import_sql.pl src/main/resources/import.sql


## Building TicketMonster

TicketMonster can be built from Maven, by runnning the following Maven command:

    mvn clean package
	
### Building TicketMonster with tests
	
If you want to run the Arquillian tests as part of the build, you can enable one of the two available Arquillian profiles.

For running the tests in an _already running_ application server instance, use the `arq-wildfly-remote` profile.

    mvn clean package -Parq-wildfly-remote

If you want the test runner to _start_ an application server instance, use the `arq-wildfly-managed` profile. You must set up the `JBOSS_HOME` property to point to the server location, or update the `src/main/test/resources/arquillian.xml` file.

    mvn clean package -Parq-wildfly-managed
	
### Building TicketMonster with Postgresql (for OpenShift)

If you intend to deploy into [OpenShift](http://openshift.com), you can use the `postgresql` and `openshift` profile

    mvn clean package -Ppostgresql,openshift,default

### Building TicketMonster with MySQL (for OpenShift)

If you intend to deploy into [OpenShift](http://openshift.com), you can use the `mysql` and `openshift` profiles

    mvn clean package -Pmysql,openshift,deafult
	
## Running TicketMonster

You can run TicketMonster into a local JBoss EAP 6.3 instance or on OpenShift.

### Running TicketMonster locally

#### Start JBoss Enterprise Application Platform 6.3

1. Open a command line and navigate to the root of the JBoss server directory.
2. The following shows the command line to start the server with the web profile:

        For Linux:   JBOSS_HOME/bin/standalone.sh
        For Windows: JBOSS_HOME\bin\standalone.bat
		
#### Deploy TicketMonster

1. Make sure you have started the JBoss Server as described above.
2. Type this command to build and deploy the archive into a running server instance.

        mvn clean package wildfly:deploy
	
	(You can use the `arq-wildfly-remote` profile for running tests as well)

3. This will deploy `target/ticket-monster.war` to the running instance of the server.
4. Now you can see the application running at `http://localhost:8080/ticket-monster`

### Running TicketMonster in OpenShift

TBD
