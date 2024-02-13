package org.ticketmonster.orders;

import org.junit.Test;
import org.ticketmonster.orders.booking.BookingRequested;
import org.ticketmonster.orders.booking.TicketRequest;

import java.util.ArrayList;
import java.util.Set;

import static org.junit.Assert.*;

/**
 * Created by ceposta
 * <a href="http://christianposta.com/blog>http://christianposta.com/blog</a>.
 */
public class BookingRequestedTest {

    @Test
    public void testUniqueTicketPriceIds() {
        BookingRequested bookingRequested = new BookingRequested();
        TicketRequest ticket = new TicketRequest();
        ticket.setTicketPrice(1L);

        ArrayList<TicketRequest> list = new ArrayList<>();
        list.add(ticket);

        ticket = new TicketRequest();
        ticket.setTicketPrice(1L);
        list.add(ticket);

        ticket = new TicketRequest();
        ticket.setTicketPrice(2L);
        list.add(ticket);

        bookingRequested.setTicketRequests(list);

        Set<Long> result = bookingRequested.getUniqueTicketPriceIds();
        assertTrue(result.size() == 2);
    }

}