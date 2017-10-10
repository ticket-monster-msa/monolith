package org.jboss.examples.ticketmonster.rest;

import org.ff4j.FF4j;
import org.jboss.examples.ticketmonster.model.*;
import org.jboss.examples.ticketmonster.orders.OrdersRequestDTO;
import org.jboss.examples.ticketmonster.service.AllocatedSeats;
import org.jboss.examples.ticketmonster.service.SeatAllocationService;
import org.jboss.examples.ticketmonster.util.qualifier.Cancelled;
import org.jboss.examples.ticketmonster.util.qualifier.Created;
import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyClientBuilder;

import javax.ejb.Stateless;
import javax.enterprise.event.Event;
import javax.inject.Inject;
import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;
import javax.ws.rs.*;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedHashMap;
import javax.ws.rs.core.Response;
import java.util.*;

/**
 * <p>
 *     A JAX-RS endpoint for handling {@link Booking}s. Inherits the GET
 *     methods from {@link BaseEntityService}, and implements additional REST methods.
 * </p>
 *
 * @author Marius Bogoevici
 * @author Pete Muir
 */
@Path("/bookings")
/**
 * <p>
 *     This is a stateless service, we declare it as an EJB for transaction demarcation
 * </p>
 */
@Stateless
public class BookingService extends BaseEntityService<Booking> {

    @Inject
    SeatAllocationService seatAllocationService;

    @Inject
    FF4j ff;

    @Inject @Cancelled
    private Event<Booking> cancelledBookingEvent;

    @Inject @Created
    private Event<Booking> newBookingEvent;

    private String ordersServiceUri = "http://localhost:9090/rest/bookings";
    
    public BookingService() {
        super(Booking.class);
    }
    
    @DELETE
    public Response deleteAllBookings() {
    	List<Booking> bookings = getAll(new MultivaluedHashMap<String, String>());
    	for (Booking booking : bookings) {
    		deleteBooking(booking.getId());
    	}
        return Response.noContent().build();
    }

    /**
     * <p>
     * Delete a booking by id
     * </p>
     * @param id
     * @return
     */
    @DELETE
    @Path("/{id:[0-9][0-9]*}")
    public Response deleteBooking(@PathParam("id") Long id) {
        Booking booking = getEntityManager().find(Booking.class, id);
        if (booking == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        getEntityManager().remove(booking);
        // Group together seats by section so that we can deallocate them in a group
        Map<Section, List<Seat>> seatsBySection = new TreeMap<Section, java.util.List<Seat>>(SectionComparator.instance());
        for (Ticket ticket : booking.getTickets()) {
            List<Seat> seats = seatsBySection.get(ticket.getSeat().getSection());
            if (seats == null) {
                seats = new ArrayList<Seat>();
                seatsBySection.put(ticket.getSeat().getSection(), seats);
            }
            seats.add(ticket.getSeat());
        }
        // Deallocate each section block
        for (Map.Entry<Section, List<Seat>> sectionListEntry : seatsBySection.entrySet()) {
            seatAllocationService.deallocateSeats( sectionListEntry.getKey(),
                    booking.getPerformance(), sectionListEntry.getValue());
        }
        cancelledBookingEvent.fire(booking);
        return Response.noContent().build();
    }

    /**
     * <p>
     *   Create a booking. Data is contained in the bookingRequest object
     * </p>
     * @param bookingRequest
     * @return
     */
    @POST
    /**
     * <p> Data is received in JSON format. For easy handling, it will be unmarshalled in the support
     * {@link BookingRequest} class.
     */
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createBooking(BookingRequest bookingRequest) {
        Response response = null;

        if (ff.check("orders-internal")) {
            System.out.println("Creating internal booking");
            response = createBookingInternal(bookingRequest);
        }

        if (ff.check("orders-service")) {
            if (ff.check("orders-internal")) {
                createSyntheticBookingOrdersService(bookingRequest);

            }
            else {
                response = createBookingOrdersService(bookingRequest);
            }
        }

        return response;
    }

    /**
     * Makes a call to the Orders Service, but lets it know that this is a synthetic transaction
     * that has already been recorded (ie, here internally) and is sent just for exercising the orders
     * service; it should roll back or clean up and not store this tx as a real tx
     *
     * @param bookingRequest
     */
    private void createSyntheticBookingOrdersService(BookingRequest bookingRequest) {
        System.out.println("Calling Orders Service with SYNTHETIC TX");
        OrdersRequestDTO ordersRequest = new OrdersRequestDTO(bookingRequest, true);

        try {
            System.out.println("Calling service: " + ordersServiceUri);
            Response response = buildClient()
                    .target(ordersServiceUri)
                    .request().post(Entity.entity(ordersRequest, MediaType.APPLICATION_JSON_TYPE));
            String sytheticResponse = response.readEntity(String.class);
            System.out.println("Response from SYNTHETIC TX: " + sytheticResponse);

        } catch (Exception e) {
            System.out.println("Caught an exception here: "+ e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private Client buildClient() {
        String proxyHost = System.getProperty("http.proxyHost");
        Integer proxyPort;
        try {
            proxyPort = Integer.parseInt(System.getProperty("http.proxyPort"));
        } catch (NumberFormatException e) {
            proxyPort = null;
        }

        if (proxyHost != null && !proxyHost.isEmpty() && proxyPort != null) {
            System.out.println("Using proxy: " + proxyHost + ":" + proxyPort);
            return new ResteasyClientBuilder()
                    .defaultProxy(proxyHost, proxyPort).build();
        }else {
            return ClientBuilder.newClient();
        }

    }

    /**
     * This method delegates the booking creation to the Orders Service
     * @param bookingRequest
     * @return
     */
    private Response createBookingOrdersService(BookingRequest bookingRequest) {
        System.out.println("Real World orders service");
        return null;
    }

    /**
     * This is the original implementation of creating a booking; relies on internal logic
     *
     * @param bookingRequest
     * @return
     */
    private Response createBookingInternal(BookingRequest bookingRequest) {
        try {
            // identify the ticket price categories in this request
            Set<Long> priceCategoryIds = bookingRequest.getUniquePriceCategoryIds();

            // load the entities that make up this booking's relationships
            Performance performance = getEntityManager().find(Performance.class, bookingRequest.getPerformance());

            // As we can have a mix of ticket types in a booking, we need to load all of them that are relevant,
            // id
            Map<Long, TicketPrice> ticketPricesById = loadTicketPrices(priceCategoryIds);

            // Now, start to create the booking from the posted data
            // Set the simple stuff first!
            Booking booking = new Booking();
            booking.setContactEmail(bookingRequest.getEmail());
            booking.setPerformance(performance);
            booking.setCancellationCode("abc");

            // Now, we iterate over each ticket that was requested, and organize them by section and category
            // we want to allocate ticket requests that belong to the same section contiguously
            Map<Section, Map<TicketCategory, TicketRequest>> ticketRequestsPerSection
                    = new TreeMap<Section, Map<TicketCategory, TicketRequest>>(SectionComparator.instance());
            for (TicketRequest ticketRequest : bookingRequest.getTicketRequests()) {
                final TicketPrice ticketPrice = ticketPricesById.get(ticketRequest.getTicketPrice());
                if (!ticketRequestsPerSection.containsKey(ticketPrice.getSection())) {
                    ticketRequestsPerSection
                            .put(ticketPrice.getSection(), new HashMap<TicketCategory, TicketRequest>());
                }
                ticketRequestsPerSection.get(ticketPrice.getSection()).put(
                        ticketPricesById.get(ticketRequest.getTicketPrice()).getTicketCategory(), ticketRequest);
            }

            // Now, we can allocate the tickets
            // Iterate over the sections, finding the candidate seats for allocation
            // The process will lock the record for a given
            // Use deterministic ordering to prevent deadlocks
            Map<Section, AllocatedSeats> seatsPerSection = new TreeMap<Section, AllocatedSeats>(SectionComparator.instance());
            List<Section> failedSections = new ArrayList<Section>();
            for (Section section : ticketRequestsPerSection.keySet()) {
                int totalTicketsRequestedPerSection = 0;
                // Compute the total number of tickets required (a ticket category doesn't impact the actual seat!)
                final Map<TicketCategory, TicketRequest> ticketRequestsByCategories = ticketRequestsPerSection.get(section);
                // calculate the total quantity of tickets to be allocated in this section
                for (TicketRequest ticketRequest : ticketRequestsByCategories.values()) {
                    totalTicketsRequestedPerSection += ticketRequest.getQuantity();
                }
                // try to allocate seats

                AllocatedSeats allocatedSeats = seatAllocationService.allocateSeats(section, performance, totalTicketsRequestedPerSection, true);
                if (allocatedSeats.getSeats().size() == totalTicketsRequestedPerSection) {
                    seatsPerSection.put(section, allocatedSeats);
                } else {
                    failedSections.add(section);
                }
            }
            if (failedSections.isEmpty()) {
                for (Section section : seatsPerSection.keySet()) {
                    // allocation was successful, begin generating tickets
                    // associate each allocated seat with a ticket, assigning a price category to it
                    final Map<TicketCategory, TicketRequest> ticketRequestsByCategories = ticketRequestsPerSection.get(section);
                    AllocatedSeats allocatedSeats = seatsPerSection.get(section);
                    allocatedSeats.markOccupied();
                    int seatCounter = 0;
                    // Now, add a ticket for each requested ticket to the booking
                    for (TicketCategory ticketCategory : ticketRequestsByCategories.keySet()) {
                        final TicketRequest ticketRequest = ticketRequestsByCategories.get(ticketCategory);
                        final TicketPrice ticketPrice = ticketPricesById.get(ticketRequest.getTicketPrice());
                        for (int i = 0; i < ticketRequest.getQuantity(); i++) {
                            Ticket ticket = new Ticket(allocatedSeats.getSeats().get(seatCounter + i), ticketCategory, ticketPrice.getPrice());
                            // getEntityManager().persist(ticket);
                            booking.getTickets().add(ticket);
                        }
                        seatCounter += ticketRequest.getQuantity();
                    }
                }
                // Persist the booking, including cascaded relationships
                booking.setPerformance(performance);
                booking.setCancellationCode("abc");
                getEntityManager().persist(booking);
                newBookingEvent.fire(booking);
                return Response.ok().entity(booking).type(MediaType.APPLICATION_JSON_TYPE).build();
            } else {
                Map<String, Object> responseEntity = new HashMap<String, Object>();
                responseEntity.put("errors", Collections.singletonList("Cannot allocate the requested number of seats!"));
                return Response.status(Response.Status.BAD_REQUEST).entity(responseEntity).build();
            }
        } catch (ConstraintViolationException e) {
            // If validation of the data failed using Bean Validation, then send an error
            Map<String, Object> errors = new HashMap<String, Object>();
            List<String> errorMessages = new ArrayList<String>();
            for (ConstraintViolation<?> constraintViolation : e.getConstraintViolations()) {
                errorMessages.add(constraintViolation.getMessage());
            }
            errors.put("errors", errorMessages);
            // A WebApplicationException can wrap a response
            // Throwing the exception causes an automatic rollback
            throw new RestServiceException(Response.status(Response.Status.BAD_REQUEST).entity(errors).build());
        } catch (Exception e) {
            // Finally, handle unexpected exceptions
            Map<String, Object> errors = new HashMap<String, Object>();
            errors.put("errors", Collections.singletonList(e.getMessage()));
            // A WebApplicationException can wrap a response
            // Throwing the exception causes an automatic rollback
            throw new RestServiceException(Response.status(Response.Status.BAD_REQUEST).entity(errors).build());
        }
    }

    /**
     * Utility method for loading ticket prices
     * @param priceCategoryIds
     * @return
     */
    private Map<Long, TicketPrice> loadTicketPrices(Set<Long> priceCategoryIds) {
        List<TicketPrice> ticketPrices = (List<TicketPrice>) getEntityManager()
                .createQuery("select p from TicketPrice p where p.id in :ids", TicketPrice.class)
                .setParameter("ids", priceCategoryIds).getResultList();
        // Now, map them by id
        Map<Long, TicketPrice> ticketPricesById = new HashMap<Long, TicketPrice>();
        for (TicketPrice ticketPrice : ticketPrices) {
            ticketPricesById.put(ticketPrice.getId(), ticketPrice);
        }
        return ticketPricesById;
    }

    public String getOrdersServiceUri() {
        return ordersServiceUri;
    }

    public void setOrdersServiceUri(String ordersServiceUri) {
        this.ordersServiceUri = ordersServiceUri;
    }
}
