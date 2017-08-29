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
import io.specto.hoverfly.junit.rule.HoverflyRule;
import org.hamcrest.Matcher;
import org.hamcrest.Matchers;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Test;

import static io.restassured.RestAssured.get;
import static io.restassured.RestAssured.given;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;
import static io.specto.hoverfly.junit.core.SimulationSource.classpath;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
public class HoverflyTest {

    @ClassRule
    public static HoverflyRule hoverflyRule = HoverflyRule.inSimulationMode(classpath("hoverfly/simulation.json"));

    @Before
    public void init() {
        RestAssured.baseURI = "http://ticketmonster.io/";
    }

    @Test
    public void testRestEventsSimulation(){
//        System.out.println(get("/rest/events").asString());
        get("/rest/events").then().assertThat().body(matchesJsonSchemaInClasspath("json-schema/rest-events.json"));
    }

    @Test
    public void testRestSingleEventSimulation() {
//        System.out.println(get("/rest/events/1").asString());
        get("/rest/events/1").then().assertThat().body(matchesJsonSchemaInClasspath("json-schema/rest-single-event.json"));
    }

    @Test
    public void testRestShowsForEventSimulation() {
//        System.out.println(get("/rest/shows?event=1").asString());
        get("/rest/shows?event=1").then().assertThat().body(matchesJsonSchemaInClasspath("json-schema/rest-shows.json"));
    }

    @Test
    public void restRestSingleShowSimulation() {
//        System.out.println(get("/rest/shows/1").asString());
        get("/rest/shows/1").then().assertThat().body(matchesJsonSchemaInClasspath("json-schema/rest-single-show.json"));
    }

    @Test
    public void testRestBookingsSimulation() {
        given().body("{\"ticketRequests\":[{\"ticketPrice\":1,\"quantity\":1}],\"email\":\"foo@bar.com\",\"performance\":2}").then().expect()
                .body(Matchers.equalTo("{\"id\":1,\"tickets\":[{\"id\":1,\"seat\":{\"rowNumber\":1,\"number\":1,\"section\":{\"id\":1,\"name\":\"A\",\"description\":\"Premier platinum reserve\",\"numberOfRows\":20,\"rowCapacity\":100,\"capacity\":2000}},\"ticketCategory\":{\"id\":1,\"description\":\"Adult\"},\"price\":219.5}],\"performance\":{\"id\":2,\"date\":1422212400000},\"cancellationCode\":\"abc\",\"createdOn\":1504014829268,\"contactEmail\":\"foo@bar.com\",\"totalTicketPrice\":219.5}"))

                .when().post("/rest/bookings");
    }


    @Test
    public void testRestSingleBookingSimulation() {
        System.out.println(get("/rest/bookings/1").asString());
        get("/rest/bookings/1").then().assertThat().body(matchesJsonSchemaInClasspath("json-schema/rest-single-booking.json"));
    }
}
