package org.jboss.examples.ticketmonster.model;

import javax.ejb.ApplicationException;

/**
 * <p>
 * The exception thrown if an error occurs in seat allocation.
 * </p>
 * <p>
 * We mark it as {@link ApplicationException} because it is part of the application logic. Also,
 * we want the container to roll back automatically when it is thrown.
 * </p>
 * 
 * @author Marius Bogoevici
 */
@SuppressWarnings("serial")
@ApplicationException(rollback = true)
public class SeatAllocationException extends RuntimeException {

    public SeatAllocationException() {
    }

    public SeatAllocationException(String s) {
        super(s);
    }

    public SeatAllocationException(String s, Throwable throwable) {
        super(s, throwable);
    }

    public SeatAllocationException(Throwable throwable) {
        super(throwable);
    }
}
