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
package org.jboss.examples.ticketmonster.test.utils;

import org.jboss.examples.ticketmonster.model.Performance;
import org.jboss.examples.ticketmonster.model.Show;
import org.jboss.examples.ticketmonster.model.TicketPrice;
import org.jboss.examples.ticketmonster.rest.BookingRequest;
import org.jboss.examples.ticketmonster.rest.ShowService;
import org.jboss.examples.ticketmonster.rest.TicketRequest;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
public class BookingUtils {

    public static BookingRequest createBookingRequest(ShowService showService,
                                                      Long showId, int performanceNo, int[]... sectionAndCategories) {
        Show show = showService.getSingleInstance(showId);

        Performance performance = new ArrayList<Performance>(show.getPerformances()).get(performanceNo);

        BookingRequest bookingRequest = new BookingRequest(performance, "bob@acme.com");

        List<TicketPrice> possibleTicketPrices = new ArrayList<TicketPrice>(show.getTicketPrices());
        int i = 1;
        for (int[] sectionAndCategory : sectionAndCategories) {
            for (TicketPrice ticketPrice : possibleTicketPrices) {
                int sectionId = sectionAndCategory[0];
                int categoryId = sectionAndCategory[1];
                if (ticketPrice.getSection().getId() == sectionId && ticketPrice.getTicketCategory().getId() == categoryId) {
                    bookingRequest.addTicketRequest(new TicketRequest(ticketPrice, i));
                    i++;
                    break;
                }
            }
        }
        return bookingRequest;
    }
}
