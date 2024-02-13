package org.ticketmonster.orders.booking;

import org.springframework.stereotype.Service;
import org.ticketmonster.orders.domain.*;

import javax.persistence.EntityManager;
import javax.persistence.LockModeType;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import java.util.List;

/**
 *
 * Helper service for allocation seats.
 *
 * @author Marius Bogoevici
 */
@Service
public class SeatAllocationService {

    @PersistenceContext(unitName = "default")
    EntityManager entityManager;

    public AllocatedSeats allocateSeats(Section section, PerformanceId performance, int seatCount, boolean contiguous) {
        SectionAllocation sectionAllocation = retrieveSectionAllocationExclusively(section, performance);
        List<Seat> seats = sectionAllocation.allocateSeats(seatCount, contiguous);
        return new AllocatedSeats(sectionAllocation, seats);
    }

    public void deallocateSeats(Section section, PerformanceId performance, List<Seat> seats) {
        SectionAllocation sectionAllocation = retrieveSectionAllocationExclusively(section, performance);
        for (Seat seat : seats) {
            if (!seat.getSection().equals(section)) {
                throw new SeatAllocationException("All seats must be in the same section!");
            }
            sectionAllocation.deallocate(seat);
        }
    }

    private SectionAllocation retrieveSectionAllocationExclusively(Section section, PerformanceId performance) {
        SectionAllocation sectionAllocationStatus = null;
        try {
            sectionAllocationStatus = (SectionAllocation) entityManager.createQuery(
                "select s from SectionAllocation s where " +
                    "s.performanceId.id = :performanceId and " +
                    "s.section.id = :sectionId")
                .setParameter("performanceId", performance.getId())
                .setParameter("sectionId", section.getId())
                .getSingleResult();
        } catch (NoResultException noSectionEx) {
            // Create the SectionAllocation since it doesn't exist
            sectionAllocationStatus = new SectionAllocation(performance, section);
            entityManager.persist(sectionAllocationStatus);
            entityManager.flush();
        }
        entityManager.lock(sectionAllocationStatus, LockModeType.PESSIMISTIC_WRITE);
        return sectionAllocationStatus;
    }
}
