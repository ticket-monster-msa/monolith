/**
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jboss.examples.ticketmonster.test.rest;

import io.specto.hoverfly.junit.rule.HoverflyRule;
import org.ff4j.FF4j;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.examples.ticketmonster.model.Performance;
import org.jboss.examples.ticketmonster.model.Show;
import org.jboss.examples.ticketmonster.model.TicketPrice;
import org.jboss.examples.ticketmonster.rest.BookingRequest;
import org.jboss.examples.ticketmonster.rest.BookingService;
import org.jboss.examples.ticketmonster.rest.ShowService;
import org.jboss.examples.ticketmonster.rest.TicketRequest;
import org.jboss.examples.ticketmonster.test.utils.BookingUtils;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.jboss.shrinkwrap.resolver.api.maven.Maven;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Test;
import org.junit.runner.RunWith;

import javax.inject.Inject;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static io.specto.hoverfly.junit.core.SimulationSource.classpath;
import static io.specto.hoverfly.junit.dsl.HoverflyDsl.service;
import static io.specto.hoverfly.junit.dsl.matchers.HoverflyMatchers.equalsTo;
import static io.specto.hoverfly.junit.verification.HoverflyVerifications.atLeastOnce;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
@RunWith(Arquillian.class)
public class ExternalBookingOrdersServiceTest {
    @Deployment
    public static WebArchive deployment() {
        File[] hoverflyFiles = Maven.resolver().resolve("io.specto:hoverfly-java:0.8.0")
                .withTransitivity().asFile();
        return RESTDeployment.deployment()
                .addClass(BookingUtils.class)
                .addAsLibraries(hoverflyFiles)
                .addAsResource("hoverfly/simulation.json");
    }

    @ClassRule
    public static HoverflyRule hoverflyRule = HoverflyRule.inSimulationMode(classpath("hoverfly/simulation.json"));

    @Before
    public void resetHoverfly() {
        hoverflyRule.resetJournal();
    }
    
    @Inject
    private BookingService bookingService;

    @Inject
    private ShowService showService;

    @Inject
    FF4j ff;



    @Test
    public void testExternalOrdersServiceSyntheticTransaction() {
        ff.enable("orders-service");
        bookingService.setOrdersServiceUri("http://ticketmonster.io/rest/bookings");
        BookingRequest br = BookingUtils.createBookingRequest(showService,1l, 0, new int[]{4, 1}, new int[]{1,1}, new int[]{3,1});
        bookingService.createBooking(br);
        hoverflyRule.verify(
                service(equalsTo("ticketmonster.io"))
                .post("/rest/bookings").anyBody(), atLeastOnce()
        );

    }

/*    @Test
    public void testExternalOrdersServiceDisableInternal() {
        ff.enable("orders-service");
        ff.disable("orders-internal");
        BookingRequest br = createBookingRequest(1l, 0, new int[]{4, 1}, new int[]{1,1}, new int[]{3,1});
        bookingService.createBooking(br);
    }*/


}
