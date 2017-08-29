package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.Ticket;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import org.jboss.examples.ticketmonster.rest.dto.SeatDTO;

public class NestedTicketDTO implements Serializable
{

   private Long id;
   private float price;
   private SeatDTO seat;

   public NestedTicketDTO()
   {
   }

   public NestedTicketDTO(final Ticket entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.price = entity.getPrice();
         this.seat = new SeatDTO(entity.getSeat());
      }
   }

   public Ticket fromDTO(Ticket entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new Ticket();
      }
      if (this.id != null)
      {
         TypedQuery<Ticket> findByIdQuery = em.createQuery(
               "SELECT DISTINCT t FROM Ticket t WHERE t.id = :entityId",
               Ticket.class);
         findByIdQuery.setParameter("entityId", this.id);
         try
         {
            entity = findByIdQuery.getSingleResult();
         }
         catch (javax.persistence.NoResultException nre)
         {
            entity = null;
         }
         return entity;
      }
      entity = em.merge(entity);
      return entity;
   }

   public Long getId()
   {
      return this.id;
   }

   public void setId(final Long id)
   {
      this.id = id;
   }

   public float getPrice()
   {
      return this.price;
   }

   public void setPrice(final float price)
   {
      this.price = price;
   }

   public SeatDTO getSeat()
   {
      return this.seat;
   }

   public void setSeat(final SeatDTO seat)
   {
      this.seat = seat;
   }
}