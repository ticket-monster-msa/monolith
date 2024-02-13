package org.ticketmonster.orders.domain;

import org.teiid.spring.annotations.InsertQuery;
import org.teiid.spring.annotations.SelectQuery;
import org.teiid.spring.annotations.UpdateQuery;

import static javax.persistence.GenerationType.IDENTITY;
import static javax.persistence.GenerationType.TABLE;

import java.io.Serializable;

import javax.persistence.*;
import javax.validation.constraints.NotNull;

/**
 * <p>
 * A ticket represents a seat sold for a particular price.
 * </p>
 * 
 * @author Shane Bryzak
 * @author Marius Bogoevici
 * @author Pete Muir
 */
/*
 * We suppress the warning about not specifying a serialVersionUID, as we are still developing this app, and want the JVM to
 * generate the serialVersionUID for us. When we put this app into production, we'll generate and embed the serialVersionUID
 */
@SuppressWarnings("serial")
@SelectQuery("SELECT id, CAST(price AS double), number, rowNumber AS row_number, section_id, ticketCategory_id AS ticket_category_id, tickets_id AS booking_id  FROM legacyDS.Ticket " +
        "UNION ALL SELECT id, price, number,  row_number, section_id, ticket_category_id, booking_id FROM ordersDS.ticket")
@InsertQuery("FOR EACH ROW \n"+
        "BEGIN ATOMIC \n" +
        "INSERT INTO ordersDS.ticket (id, price, number,  row_number, section_id, ticket_category_id) values (NEW.id, CAST(NEW.price as float),  NEW.number,  NEW.row_number, NEW.section_id, NEW.ticket_category_id);\n" +
        "END")
@UpdateQuery("FOR EACH ROW\n" +
        "BEGIN\n" +
        "  IF(changing.booking_id) \n" +
        "  BEGIN\n" +
        "      UPDATE ordersDS.ticket set booking_id=NEW.booking_id where id = old.id;\n" +
        "  END\n" +
        "END")
@Entity
@Table(name = "ticket")
public class Ticket implements Serializable {

    /* Declaration of fields */

    @TableGenerator(name = "ticket",
            table = "id_generator",
            pkColumnName = "idKey",
            valueColumnName = "idvalue",
            pkColumnValue = "ticket",
            allocationSize = 1)
    @Id
    @GeneratedValue(strategy = TABLE, generator = "ticket")
    private Long id;

    /**
     * <p>
     * The seat for which this ticket has been sold.
     * </p>
     * 
     * <p>
     * The seat must be specifed, and the Bean Validation constraint <code>@NotNull</code> ensures this.
     * </p>
     */
    @NotNull
    @Embedded
    private Seat seat;

    /**
     * <p>
     * The ticket price category for which this ticket has been sold.
     * </p>
     * 
     * <p>
     * The ticket price category must be specifed, and the Bean Validation constraint <code>@NotNull</code> ensures this.
     * </p>
     */
    @ManyToOne
    @NotNull
    private TicketCategory ticket_category;

    /**
     * The price which was charged for the ticket.
     */
    private float price;

    /** No-arg constructor for persistence */
    public Ticket() {

    }

    public Ticket(Seat seat, TicketCategory ticketCategory, float price) {
        this.seat = seat;
        this.ticket_category = ticketCategory;
        this.price = price;
    }

    /* Boilerplate getters and setters */

    public Long getId() {
        return id;
    }

    public TicketCategory getTicketCategory() {
        return ticket_category;
    }

    public float getPrice() {
        return price;
    }

    public Seat getSeat() {
        return seat;
    }
    
    @Override
    public String toString() {
        return new StringBuilder().append(getSeat()).append(" @ ").append(getPrice()).append(" (").append(getTicketCategory()).append(")").toString(); 
    }
}
