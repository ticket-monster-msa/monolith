package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.TicketPrice;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;

public class NestedTicketPriceDTO implements Serializable
{

   private Long id;
   private float price;
   private String displayTitle;

   public NestedTicketPriceDTO()
   {
   }

   public NestedTicketPriceDTO(final TicketPrice entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.price = entity.getPrice();
         this.displayTitle = entity.toString();
      }
   }

   public TicketPrice fromDTO(TicketPrice entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new TicketPrice();
      }
      if (this.id != null)
      {
         TypedQuery<TicketPrice> findByIdQuery = em
               .createQuery(
                     "SELECT DISTINCT t FROM TicketPrice t WHERE t.id = :entityId",
                     TicketPrice.class);
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
      entity.setPrice(this.price);
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

   public String getDisplayTitle()
   {
      return this.displayTitle;
   }
}
