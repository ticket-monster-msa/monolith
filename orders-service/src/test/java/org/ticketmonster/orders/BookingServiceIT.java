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
package org.ticketmonster.orders;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.context.embedded.LocalServerPort;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasItems;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class BookingServiceIT {

    @LocalServerPort
    int port;

    @Before
    public void init() {
        RestAssured.port=port;
    }

    @Test
    public void testSimpleBooking() throws InterruptedException {


        given().contentType(ContentType.JSON).body("{\"ticketRequests\":[{\"ticketPrice\":4,\"quantity\":3}],\"email\":\"foo@bar.coom\",\"performance\":1}")
                .and().expect()
//                .body(equalTo("foo"))
                .body("tickets.seat.number", hasItems(1,2,3)).and()
                .body("contactEmail", equalTo("foo@bar.coom"))
                .body("totalTicketPrice", equalTo(448.5f))
                .when().post("/rest/bookings");

    }
}
