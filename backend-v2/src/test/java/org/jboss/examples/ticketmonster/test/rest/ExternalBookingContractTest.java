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

import au.com.dius.pact.consumer.dsl.DslPart;
import au.com.dius.pact.consumer.dsl.PactDslJsonBody;
import au.com.dius.pact.consumer.dsl.PactDslWithProvider;
import au.com.dius.pact.model.RequestResponsePact;
import org.arquillian.algeron.consumer.StubServer;
import org.arquillian.algeron.pact.consumer.spi.Pact;
import org.arquillian.algeron.pact.consumer.spi.PactVerification;
import org.ff4j.FF4j;
import org.jboss.arquillian.container.test.api.Deployment;
import org.jboss.arquillian.junit.Arquillian;
import org.jboss.examples.ticketmonster.orders.OrdersRequestDTO;
import org.jboss.examples.ticketmonster.rest.BookingRequest;
import org.jboss.examples.ticketmonster.rest.BookingService;
import org.jboss.examples.ticketmonster.rest.ShowService;
import org.jboss.examples.ticketmonster.test.utils.BookingUtils;
import org.jboss.shrinkwrap.api.spec.WebArchive;
import org.junit.Test;
import org.junit.runner.RunWith;

import javax.inject.Inject;
import java.io.IOException;
import java.net.URL;


/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
@RunWith(Arquillian.class)
public class ExternalBookingContractTest {

    @Deployment
    public static WebArchive deployment() {
        return RESTDeployment.deployment()
                .addClass(BookingUtils.class)
                .addClass(OrdersRequestDTO.class);

    }


    @Pact(provider="orders_service", consumer="test_synthetic_order")
    public RequestResponsePact createFragment(PactDslWithProvider builder) {
        RequestResponsePact pact = builder
                .given("available shows")
                .uponReceiving("booking request")
                .path("/rest/bookings")
                .matchHeader("Content-Type", "application/json")
                .method("POST")
                .body(bookingRequestBody())
                .willRespondWith()
                .body(syntheticBookingResponseBody())
                .status(200)
                .toPact();
        return pact;
    }

    private DslPart bookingRequestBody(){
        PactDslJsonBody body = new PactDslJsonBody();
        body
                .integerType("performance", 1)
                .booleanType("synthetic", true)
                .stringType("email", "foo@bar.com")
                    .minArrayLike("ticketRequests", 1)
                        .integerType("ticketPrice", 1)
                        .integerType("quantity")
                    .closeObject()
                .closeArray();


        return body;
    }


    private DslPart syntheticBookingResponseBody() {
        PactDslJsonBody body = new PactDslJsonBody();
        body
                .booleanType("synthetic", true);
        return body;
    }

    private DslPart bookingResponseBody() {
        PactDslJsonBody body = new PactDslJsonBody();
        body.id()
                .booleanType("synthetic", true)
                .minArrayLike("tickets", 1)
                    .id()
                        .object("seat")
                            .integerType("rowNumber")
                            .integerType("number")
                            .object("section")
                                .id()
                                .stringType("name")
                                .stringType("description")
                                .integerType("numberOfRows")
                                .integerType("rowCapacity")
                                .integerType("capacity")
                            .closeObject()
                        .closeObject()
                    .closeObject()
                .closeArray()


        ;
        return body;
    }

    @Inject
    private BookingService bookingService;

    @Inject
    private ShowService showService;

    @Inject
    FF4j ff;

    @StubServer
    URL url;

    @Test
    @PactVerification("orders_service")
    public void runTest() throws IOException {
        ff.enable("orders-service");

        String ordersServiceUrl = url.toString() + "/rest/bookings";
        System.out.println(ordersServiceUrl);
        bookingService.setOrdersServiceUri(ordersServiceUrl);
        BookingRequest br = BookingUtils.createBookingRequest(showService,1l, 0, new int[]{4, 1}, new int[]{1,1}, new int[]{3,1});
        bookingService.createBooking(br);

    }
}
