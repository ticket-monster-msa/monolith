package org.ticketmonster.orders.domain;

import static javax.persistence.CascadeType.ALL;
import static javax.persistence.FetchType.EAGER;
import static javax.persistence.GenerationType.IDENTITY;
import static javax.persistence.GenerationType.TABLE;

import java.io.Serializable;
import java.util.Date;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.*;
import javax.validation.Valid;
import javax.validation.constraints.NotNull;

import org.hibernate.validator.constraints.Email;
import org.hibernate.validator.constraints.NotEmpty;
import org.teiid.spring.annotations.InsertQuery;
import org.teiid.spring.annotations.SelectQuery;
import org.teiid.spring.annotations.UpdateQuery;

/**
 * <p>
 * A Booking represents a set of tickets purchased for a performanceId.
 * </p>
 * 
 * <p>
 * Booking's principle members are a <em>set</em> of tickets, and the performanceId for which the tickets are booked. It also
 * contains meta-data about the booking, including a contact for the booking, a booking date and a cancellation code
 * </p>
 * 
 * @author Marius Bogoevici
 */
@SuppressWarnings("serial")
@Table(name="all_bookings")
@SelectQuery("SELECT b.id, b.cancellationCode AS cancellation_code, b.contactEmail AS contact_email, b.createdOn AS created_on, b.performance_id, e.name as performance_name " +
        "FROM legacyDS.Booking b " +
        "JOIN legacyDS.Performance p ON b.performance_id=p.id " +
        "JOIN legacyDS.Appearance s ON p.show_id = s.id " +
        "JOIN legacyDS.Event e ON s.event_id=e.id " +
        "UNION ALL " +
        "SELECT id, cancellation_code, contact_email, created_on, performance_id, performance_name " +
        "FROM ordersDS.booking;")
@InsertQuery("FOR EACH ROW \n"+
        "BEGIN ATOMIC \n" +
        "INSERT INTO ordersDS.booking (id, performance_id, performance_name, cancellation_code, created_on, contact_email ) values (NEW.id, NEW.performance_id, NEW.performance_name, NEW.cancellation_code, NEW.created_on, NEW.contact_email);\n" +
        "END")
@Entity
public class Booking implements Serializable {

    /* Declaration of fields */

    @TableGenerator(name = "booking",
    table = "id_generator",
    pkColumnName = "idKey",
    valueColumnName = "idvalue",
    pkColumnValue = "booking",
    allocationSize = 1)
    @Id
    @GeneratedValue(strategy = TABLE, generator = "booking")
    private Long id;

    /**
     * <p>
     * The set of tickets contained within the booking. The <code>@OneToMany<code> JPA mapping establishes this relationship.
     * </p>
     * 
     * <p>
     * The set of tickets is eagerly loaded because
     * booking is removed, then all associated tickets will be removed.
     * </p>
     * 
     * <p>
     * This relationship is uni-directional, so we need to inform JPA to create a foreign key mapping. The foreign key mapping
     * is not visible in the {@link Ticket} entity despite being present in the database.
     * </p>
     * 
     */
    @OneToMany(fetch = EAGER, cascade = ALL)
    @JoinColumn(name = "booking_id")
    @NotEmpty
    @Valid
    private Set<Ticket> tickets = new HashSet<Ticket>();

    /**
     * The performanceId of the show with which the booking is validated. The
     * <code>@ManyToOne<code> JPA mapping establishes this relationship.
     */
    @NotNull
    @Embedded
    private PerformanceId performanceId;

    /**
     * <p>
     * A cancellation code, provided to the ticket booker to allow them to cancel a booking.
     * </p>
     * 
     * <p>
     * The
     * <code>@NotEmpty<code> Bean Validation constraint means that the booking must contain a cancellation code of at least 1 character.
     * </p>
     */
    @NotEmpty
    @Column(name = "cancellation_code")
    private String cancellationCode;

    /**
     * <p>
     * The date the booking was made.
     * </p>
     * <p>
     * <p>
     * The <code>@NotNull</code> Bean Validation constraint means that the booking date must be set. By default, it is set to
     * the date the object was created.
     * </p>
     */
    @NotNull
    @Column(name = "created_on")
    private Timestamp createdOn = new Timestamp(new Date().getTime());

    /**
     * <p>
     * A contact for the booking, in case the event organizers need to contact the booker. In a later iteration of this demo
     * application, this will be replaced by a full user management system, but this wasn't part of the initial requirements.
     * </p>
     * 
     * <p>
     * Two constraints are applied using Bean Validation
     * </p>
     * 
     * <ol>
     * <li><code>@NotEmpty</code> &mdash; the string must not be null, and must have at least one character.</li>
     * <li><code>@Email</code> &mdash; the string must be a valid email address</li>
     * </ol>
     * 
     */
//    @NotEmpty
    @Email(message = "Not a valid email format")
    @Column(name = "contact_email")
    private String contactEmail;

    /**
     * Compute the total price of all tickets in this booking.
     */
    public float getTotalTicketPrice() {
        float totalPrice = 0.0f;
        for (Ticket ticket : tickets) {
            totalPrice += (ticket.getPrice());
        }
        return totalPrice;
    }

    /* Boilerplate getters and setters */

    public Long getId() {
        return id;
    }

    public Set<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(Set<Ticket> tickets) {
        this.tickets = tickets;
    }

    public Timestamp getCreatedOn() {
        return createdOn;
    }

    public void setCreatedOn(Timestamp createdOn) {
        this.createdOn = createdOn;
    }

    public String getCancellationCode() {
        return cancellationCode;
    }

    public void setCancellationCode(String cancellationCode) {
        this.cancellationCode = cancellationCode;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public PerformanceId getPerformanceId() {
        return performanceId;
    }

    public void setPerformanceId(PerformanceId performanceId) {
        this.performanceId = performanceId;
    }

    /* equals() and hashCode() for Booking, using the synthetic identity of the object */

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (o == null || getClass() != o.getClass())
            return false;

        Booking booking = (Booking) o;

        if (id != null ? !id.equals(booking.id) : booking.id != null)
            return false;

        return true;
    }

    @Override
    public int hashCode() {
        return id != null ? id.hashCode() : 0;
    }
}
