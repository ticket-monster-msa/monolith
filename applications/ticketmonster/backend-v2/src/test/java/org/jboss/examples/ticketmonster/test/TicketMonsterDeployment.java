package org.jboss.examples.ticketmonster.test;

import org.jboss.examples.ticketmonster.util.Resources;
import org.jboss.shrinkwrap.api.ShrinkWrap;
import org.jboss.shrinkwrap.api.asset.EmptyAsset;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.jboss.shrinkwrap.resolver.api.maven.Maven;

import java.io.File;

public class TicketMonsterDeployment {

    public static WebArchive deployment() {

        File[] ff4jDeps = Maven.resolver().resolve("org.ff4j:ff4j-core:1.6.5")
                .withTransitivity().asFile();
        return ShrinkWrap
                .create(WebArchive.class, "test.war")
                .addPackage(Resources.class.getPackage())
                .addAsResource("META-INF/test-persistence.xml", "META-INF/persistence.xml")
                .addAsResource("import.sql")
                .addAsWebInfResource(EmptyAsset.INSTANCE, "beans.xml")
                // Deploy our test datasource
                .addAsWebInfResource("test-ds.xml")
                .addAsLibraries(ff4jDeps)
                .addAsResource("ff4j.xml")
                ;
    }
}
