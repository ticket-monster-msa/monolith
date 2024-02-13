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
package org.ticketmonster.orders.booking;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.ticketmonster.orders.domain.*;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.*;

/**
 * Created by ceposta 
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
@RestController
@RequestMapping("/rest/bookings")
public class BookingServiceController {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    SeatAllocationService seatAllocationService;

    @RequestMapping(method = RequestMethod.POST, consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @Transactional
    public Booking createBooking(@RequestBody BookingRequested bookingRequest) {
        try {
            // identify the ticket price ids in this request
            Set<Long> ticketPriceIds = bookingRequest.getUniqueTicketPriceIds();

            // As we can have a mix of ticket types in a booking, we need to load all of them that are relevant,
            // id
            Map<Long, TicketPriceGuide> ticketPricesById = loadTicketPrices(ticketPriceIds);

            // Now, start to create the booking from the posted data
            // Set the simple stuff first!

            // todo lookup the performance and make sure it's valid as well as get its name
            PerformanceId performance = new PerformanceId(bookingRequest.getPerformance(), "Hardcoded Perf Name -- need to lookup");

            Booking booking = new Booking();
            booking.setContactEmail(bookingRequest.getEmail());
            booking.setPerformanceId(performance);

            // TODO ceposta: why is this hardcoed?
            booking.setCancellationCode("abc");

            // Now, we iterate over each ticket that was requested, and organize them by section. Each
            // section will have a map of ticketCategory->ticketsRequested
            // we want to allocate ticket requests that belong to the same section contiguously
            Map<Section, Map<TicketCategory, TicketRequest>> ticketRequestsPerSection
                    = new TreeMap<Section, java.util.Map<TicketCategory, TicketRequest>>(SectionComparator.instance());

            for (TicketRequest ticketRequest : bookingRequest.getTicketRequests()) {

                final TicketPriceGuide ticketPriceGuide = ticketPricesById.get(ticketRequest.getTicketPriceGuideId());

                if (!ticketRequestsPerSection.containsKey(ticketPriceGuide.getSection())) {
                    ticketRequestsPerSection
                            .put(ticketPriceGuide.getSection(), new HashMap<TicketCategory, TicketRequest>());
                }
                ticketRequestsPerSection.get(ticketPriceGuide.getSection())
                        .put(extractTicketCategory(ticketPricesById, ticketRequest), ticketRequest);
            }

            // Now, we can allocate the tickets
            // Iterate over the sections, finding the candidate seats for allocation
            // The process will lock the record for a given
            // Use deterministic ordering to prevent deadlocks
            Map<Section, AllocatedSeats> allocatedSeatsPerSection = new TreeMap<Section, AllocatedSeats>(SectionComparator.instance());

            List<Section> failedSections = new ArrayList<Section>();

            for (Section section : ticketRequestsPerSection.keySet()) {
                int totalTicketsRequestedPerSection = 0;
                // Compute the total number of tickets required (a ticket category doesn't impact the actual seat!)
                final Map<TicketCategory, TicketRequest> ticketRequestsByCategories = ticketRequestsPerSection.get(section);
                // calculate the total quantity of tickets to be allocated in this section
                for (TicketRequest ticketRequest : ticketRequestsByCategories.values()) {
                    totalTicketsRequestedPerSection += ticketRequest.getQuantity();
                }

                // *********************
                // try to allocate seats
                // *********************
                AllocatedSeats allocatedSeats = seatAllocationService.allocateSeats(section, performance, totalTicketsRequestedPerSection, true);
                if (allocatedSeats.getSeats().size() == totalTicketsRequestedPerSection) {
                    allocatedSeatsPerSection.put(section, allocatedSeats);
                } else {
                    failedSections.add(section);
                }
            }

            // if there are no failed sections, return success!!
            // this is kinda silly though because we may still want to allocate sections up to what we can and
            // ask display to the user which allocations we could get and let them decide what they want to do?
            // or we have a reservation step before they get the payment which will give them that information.
            if (failedSections.isEmpty()) {
                for (Section section : allocatedSeatsPerSection.keySet()) {
                    // allocation was successful, begin generating tickets
                    // associate each allocated seat with a ticket, assigning a price category to it
                    final Map<TicketCategory, TicketRequest> ticketRequestsByCategories = ticketRequestsPerSection.get(section);
                    AllocatedSeats allocatedSeats = allocatedSeatsPerSection.get(section);
                    allocatedSeats.markOccupied();
                    int seatCounter = 0;
                    // Now, add a ticket for each requested ticket to the booking
                    for (TicketCategory ticketCategory : ticketRequestsByCategories.keySet()) {
                        final TicketRequest ticketRequest = ticketRequestsByCategories.get(ticketCategory);
                        final TicketPriceGuide ticketPriceGuide = ticketPricesById.get(ticketRequest.getTicketPriceGuideId());
                        for (int i = 0; i < ticketRequest.getQuantity(); i++) {
                            Ticket ticket = new Ticket(allocatedSeats.getSeats().get(seatCounter + i), ticketCategory, ticketPriceGuide.getPrice());
                            // getEntityManager().persist(ticket);
                            booking.getTickets().add(ticket);
                        }
                        seatCounter += ticketRequest.getQuantity();
                    }
                }
                // Persist the booking, including cascaded relationships
                booking.setPerformanceId(performance);
                booking.setCancellationCode("abc");

                if (bookingRequest.isSynthetic()) {
                    System.out.println("This is a synthetic transaction, ignoring");
                    SyntheticBooking syntheticBooking = new SyntheticBooking(booking);
                    return syntheticBooking;
                }
                else {
                    entityManager.persist(booking);
                    return booking;
                }

            } else {

                // cannot allocated all the sections so we just error out!?
                // TODO ceposta: we need to change this so we still allocate some? and report back how many we got?
                // and possibly ask about a waitlist?
                Map<String, Object> responseEntity = new HashMap<String, Object>();
                responseEntity.put("errors", Collections.singletonList("Cannot allocate the requested number of seats!"));
                throw new RestServiceException(responseEntity);
            }
        } catch (Exception e) {
            // Finally, handle unexpected exceptions
            e.printStackTrace();
            Map<String, Object> errors = new HashMap<String, Object>();
            errors.put("errors", Collections.singletonList(e.getMessage()));
            errors.put("stacktrace", Collections.singletonList(getStackTrace(e)));
            // A WebApplicationException can wrap a response
            // Throwing the exception causes an automatic rollback
            throw new RestServiceException(errors);
        }

    }

    private TicketCategory extractTicketCategory(Map<Long, TicketPriceGuide> ticketPricesById, TicketRequest ticketRequest) {
        return ticketPricesById.get(ticketRequest.getTicketPriceGuideId()).getTicketCategory();
    }

    private String getStackTrace(Exception e) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        return sw.toString();
    }

    private Map<Long, TicketPriceGuide> loadTicketPrices(Set<Long> priceCategoryIds) {
        List<TicketPriceGuide> ticketPriceGuides = (List<TicketPriceGuide>) entityManager
                .createQuery("select p from TicketPriceGuide p where p.id in :ids", TicketPriceGuide.class)
                .setParameter("ids", priceCategoryIds).getResultList();
        // Now, map them by id
        Map<Long, TicketPriceGuide> ticketPricesById = new HashMap<Long, TicketPriceGuide>();
        for (TicketPriceGuide ticketPriceGuide : ticketPriceGuides) {
            ticketPricesById.put(ticketPriceGuide.getId(), ticketPriceGuide);
        }
        return ticketPricesById;
    }
}
