package org.ticketmonster.orders.domain;


import org.teiid.spring.annotations.InsertQuery;
import org.teiid.spring.annotations.SelectQuery;
import org.teiid.spring.annotations.UpdateQuery;

import static javax.persistence.GenerationType.IDENTITY;
import static javax.persistence.GenerationType.TABLE;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.persistence.*;
import javax.validation.constraints.NotNull;

/**
 * <p>
 * Represents the state of ticket allocation in a section, for a specific performanceId.
 * </p>
 * 
 * <p>
 * Optimistic locking ensures that two tickets will not be sold within the same row. Adding a member annotated with
 * <code>@Version</code> enables optimistic locking.
 * </p>
 * 
 * <p>
 * The performanceId and section form the natural id of this entity, and therefore must be unique. JPA requires us to use the
 * class level <code>@Table</code> constraint.
 * </p>
 * 
 * @author Marius Bogoevici
 * @author Pete Muir
 */
@SelectQuery("SELECT sa.id, sa.allocated, sa.occupiedCount AS occupied_count, sa.performance_id, e.name as performance_name, sa.version, sa.section_id " +
        "FROM legacyDS.SectionAllocation sa " +
        "JOIN legacyDS.Performance p ON sa.performance_id=p.id " +
        "JOIN legacyDS.Appearance s ON p.show_id=s.id " +
        "JOIN legacyDS.Event e ON s.event_id=e.id;")
@InsertQuery("FOR EACH ROW \n"+
        "BEGIN ATOMIC \n" +
        "INSERT INTO legacyDS.SectionAllocation (id, allocated, occupiedCount, version, performance_id, section_id) values (NEW.id, NEW.allocated, NEW.occupied_count, NEW.version, NEW.performance_id, NEW.section_id);\n" +
        "END")
@UpdateQuery("FOR EACH ROW \n" +
        "BEGIN ATOMIC \n " +
        "UPDATE legacyDS.SectionAllocation SET version=NEW.version, allocated=NEW.allocated, occupiedCount=NEW.occupied_count WHERE id=OLD.id;" +
        "END")
@Entity
@Table(name="section_allocation", uniqueConstraints = @UniqueConstraint(columnNames = { "performance_id", "section_id" }))
public class SectionAllocation implements Serializable {
    @Transient
    private static final int EXPIRATION_TIME = 60 * 1000;

    /* Declaration of fields */

    @TableGenerator(name = "section_allocation",
            table = "id_generator",
            pkColumnName = "idKey",
            valueColumnName = "idvalue",
            pkColumnValue = "section_allocation",
            allocationSize = 1)
    @Id
    @GeneratedValue(strategy = TABLE, generator = "section_allocation")
    private Long id;

    /**
     * <p>
     * The version used to optimistically lock this entity.
     * </p>
     * 
     * <p>
     * Adding this field enables optimistic locking. As we don't access this field in the application, we need to suppress the
     * warnings the java compiler gives us about not using the field!
     * </p>
     */
    @SuppressWarnings("unused")
    @Version
    private long version;

    /**
     * <p>
     * The performanceId to which this allocation relates. The <code>@ManyToOne<code> JPA mapping establishes this relationship.
     * </p>
     * 
     * <p>
     * The performanceId must be specified, so we add the Bean Validation constrain <code>@NotNull</code>
     * </p>
     */
    @NotNull
    @Embedded
    private PerformanceId performanceId;

    /**
     * <p>
     * The section to which this allocation relates. The <code>@ManyToOne<code> JPA mapping establishes this relationship.
     * </p>
     * 
     * <p>
     * The section must be specified, so we add the Bean Validation constrain <code>@NotNull</code>
     * </p>
     */
    @ManyToOne
    @NotNull
    private Section section;

    /**
     * <p>
     * A two dimensional matrix of allocated seats in a section, represented by a 2 dimensional array.
     * </p>
     * 
     * <p>
     * A two dimensional array doesn't have a natural RDBMS mapping, so we simply store this a binary object in the database, an
     * approach which requires no additional mapping logic. Any analysis of which seats within a section are allocated is done
     * in the business logic, below, not by the RDBMS.
     * </p>
     * 
     * <p>
     * <code>@Lob</code> instructs JPA to map this a large object in the database
     * </p>
     */
    @Lob
    private long[][] allocated;

    /**
     * <p>
     *     The number of occupied seats in a section. It is updated whenever tickets are sold or canceled.
     * </p>
     *
     * <p>
     *     This field contains a summary of the information found in the <code>allocated</code> fields, and
     *     it is intended to be used for analytics purposes only.
     * </p>
     */
    @Column(name = "occupied_count")
    private int occupiedCount = 0;

    /**
     * Constructor for persistence
     */
    public SectionAllocation() {
    }

    public SectionAllocation(PerformanceId performanceId, Section section) {
        this.performanceId = performanceId;
        this.section = section;
        this.allocated = new long[section.getNumberOfRows()][section.getRowCapacity()];
        for (long[] seatStates : (long[][])allocated) {
            Arrays.fill(seatStates, 0l);
        }
    }

    /**
     * Post-load callback method initializes the allocation table if it not populated already
     * for the entity
     */
    @PostLoad
    void initialize() {
    	if (this.allocated == null) {
    		this.allocated = new long[this.section.getNumberOfRows()][this.section.getRowCapacity()];
            for (long[] seatStates : allocated) {
                Arrays.fill(seatStates, 0l);
            }
        }
    }

    /**
     * Check if a particular seat is allocated in this section for this performance.
     * 
     * @return true if the seat is allocated, otherwise false
     */
    public boolean isAllocated(Seat s) {
        // Examine the allocation matrix, using the row and seat number as indices
        return allocated[s.getRowNumber() - 1][s.getNumber() - 1] != 0;
    }

    /**
     * Allocate the specified number seats within this section for this performance. Optionally allocate them in a contiguous
     * block.
     * 
     * @param seatCount the number of seats to allocate
     * @param contiguous whether the seats must be allocated in a contiguous block or not
     * @return the allocated seats
     */
    public ArrayList<Seat> allocateSeats(int seatCount, boolean contiguous) {
        // The list of seats allocated
        ArrayList<Seat> seats = new ArrayList<Seat>();

        // The seat allocation algorithm starts by iterating through the rows in this section
        for (int rowCounter = 0; rowCounter < section.getNumberOfRows(); rowCounter++) {

            if (contiguous) {
                // identify the first block of free seats of the requested size
                int startSeat = findFreeGapStart(rowCounter, 0, seatCount);
                // if a large enough block of seats is available
                if (startSeat >= 0) {
                    // Create the list of allocated seats to return
                    for (int i = 1; i <= seatCount; i++) {
                        seats.add(new Seat(section, rowCounter + 1, startSeat + i));
                    }
                    // Seats are allocated now, so we can stop checking rows
                    break;
                }
            } else {
                // As we aren't allocating contiguously, allocate each seat needed, one at a time
                int startSeat = findFreeGapStart(rowCounter, 0, 1);
                // if a seat is found
                if (startSeat >= 0) {
                    do {
                        // Create the seat to return to the user
                        seats.add(new Seat(section, rowCounter + 1, startSeat + 1));
                        // Find the next free seat in the row
                        startSeat = findFreeGapStart(rowCounter, startSeat, 1);
                    } while (startSeat >= 0 && seats.size() < seatCount);
                    if (seats.size() == seatCount) {
                        break;
                    }
                }
            }
        }
        // Simple check to make sure we could actually allocate the required number of seats

        if (seats.size() == seatCount) {
            for (Seat seat : seats) {
                allocate(seat.getRowNumber() - 1, seat.getNumber() - 1, 1, expirationTimestamp());
            }
            return seats;
        } else {
            return new ArrayList<Seat>(0);
        }
    }

    public void markOccupied(List<Seat> seats) {
        for (Seat seat : seats) {
            allocate(seat.getRowNumber() - 1, seat.getNumber() - 1, 1, -1);
        }
    }

    /**
     * Helper method which can locate blocks of seats
     * 
     * @param row The row number to check
     * @param startSeat The seat to start with in the row
     * @param size The size of the block to locate
     * @return
     */
    private int findFreeGapStart(int row, int startSeat, int size) {

        // An array of occupied seats in the row
        long[] occupied = allocated[row];
        int candidateStart = -1;

        // Iterate over the seats, and locate the first free seat block
        for (int i = startSeat; i < occupied.length; i++) {
            // if the seat isn't allocated
            long currentTimestamp = System.currentTimeMillis();
            if (occupied[i] >=0 && currentTimestamp > occupied[i]) {
                // then set this as a possible start
                if (candidateStart == -1) {
                    candidateStart = i;
                }
                // if we've counted out enough seats since the possible start, then we are done
                if ((size == (i - candidateStart + 1))) {
                    return candidateStart;
                }
            } else {
                candidateStart = -1;
            }
        }
        return -1;
    }

    /**
     * Helper method to allocate a specific block of seats
     * 
     * @param row the row in which the seat should be allocated
     * @param start the seat number to start allocating from
     * @param size the size of the block to allocate
     * @throws SeatAllocationException if less than 1 seat is to be allocated
     * @throws SeatAllocationException if the first seat to allocate is more than the number of seats in the row
     * @throws SeatAllocationException if the last seat to allocate is more than the number of seats in the row
     * @throws SeatAllocationException if the seats are already occupied.
     */
    private void allocate(int row, int start, int size, long finalState) throws SeatAllocationException {
        long[] occupied = allocated[row];
        if (size <= 0) {
            throw new SeatAllocationException("Number of seats must be greater than zero");
        }
        if (start < 0 || start >= occupied.length) {
            throw new SeatAllocationException("Seat number must be betwen 1 and " + occupied.length);
        }
        if ((start + size) > occupied.length) {
            throw new SeatAllocationException("Cannot allocate seats above row capacity");
        }

        // Now that we know we can allocate the seats, set them to occupied in the allocation matrix
        for (int i = start; i < (start + size); i++) {
            occupied[i] = finalState;
            occupiedCount++;
        }

    }

    /**
     * Dellocate a seat within this section for this performance.
     *
     * @param seat the seats that need to be deallocated
     */
    public void deallocate(Seat seat) {
        if (!isAllocated(seat)) {
            throw new SeatAllocationException("Trying to deallocate an unallocated seat!");
        }
        this.allocated[seat.getRowNumber()-1][seat.getNumber()-1] = 0;
        occupiedCount --;
    }

    /* Boilerplate getters and setters */

    public int getOccupiedCount() {
        return occupiedCount;
    }

    public PerformanceId getPerformanceId() {
        return performanceId;
    }

    public Section getSection() {
        return section;
    }

    public Long getId() {
        return id;
    }

    private long expirationTimestamp() {
        return System.currentTimeMillis() + EXPIRATION_TIME;
    }

}
