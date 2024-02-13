package org.jboss.examples.ticketmonster.rest;

import org.jboss.examples.ticketmonster.model.TicketPrice;

/**
 * <p>
 * A {@link BookingRequest} will contain multiple {@link TicketRequest}s.
 * </p>
 * 
 * @author Marius Bogoevici
 * @author Pete Muir
 * 
 */
public class TicketRequest {

    private long ticketPrice;

    private int quantity;

    public TicketRequest() {
        // Empty constructor
    }

    public TicketRequest(TicketPrice ticketPrice, int quantity) {
        this.ticketPrice = ticketPrice.getId();
        this.quantity = quantity;
    }

    public long getTicketPrice() {
        return ticketPrice;
    }

    public void setTicketPrice(long ticketPrice) {
        this.ticketPrice = ticketPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
