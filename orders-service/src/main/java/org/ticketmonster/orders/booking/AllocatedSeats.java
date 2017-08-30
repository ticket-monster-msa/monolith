package org.ticketmonster.orders.booking;


import org.ticketmonster.orders.domain.Seat;
import org.ticketmonster.orders.domain.SectionAllocation;

import java.util.List;

/**
 * A transient object which represents a collection of pre-allocated seats
 *
 * @author Marius Bogoevici
 */
public class AllocatedSeats {

    private final SectionAllocation sectionAllocation;

    private final List<Seat> seats;

    public AllocatedSeats(SectionAllocation sectionAllocation, List<Seat> seats) {
        this.sectionAllocation = sectionAllocation;
        this.seats = seats;
    }

    public SectionAllocation getSectionAllocation() {
        return sectionAllocation;
    }

    public List<Seat> getSeats() {
        return seats;
    }

    public void markOccupied() {
        sectionAllocation.markOccupied(seats);
    }
}
