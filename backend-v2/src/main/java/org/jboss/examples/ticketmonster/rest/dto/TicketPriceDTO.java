package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.TicketPrice;
import javax.persistence.EntityManager;
import org.jboss.examples.ticketmonster.rest.dto.NestedShowDTO;
import org.jboss.examples.ticketmonster.rest.dto.NestedSectionDTO;
import org.jboss.examples.ticketmonster.rest.dto.NestedTicketCategoryDTO;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class TicketPriceDTO implements Serializable
{

   private Long id;
   private NestedShowDTO show;
   private NestedSectionDTO section;
   private NestedTicketCategoryDTO ticketCategory;
   private float price;
   private String displayTitle;

   public TicketPriceDTO()
   {
   }

   public TicketPriceDTO(final TicketPrice entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.show = new NestedShowDTO(entity.getShow());
         this.section = new NestedSectionDTO(entity.getSection());
         this.ticketCategory = new NestedTicketCategoryDTO(
               entity.getTicketCategory());
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
      if (this.show != null)
      {
         entity.setShow(this.show.fromDTO(entity.getShow(), em));
      }
      if (this.section != null)
      {
         entity.setSection(this.section.fromDTO(entity.getSection(), em));
      }
      if (this.ticketCategory != null)
      {
         entity.setTicketCategory(this.ticketCategory.fromDTO(
               entity.getTicketCategory(), em));
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

   public NestedShowDTO getShow()
   {
      return this.show;
   }

   public void setShow(final NestedShowDTO show)
   {
      this.show = show;
   }

   public NestedSectionDTO getSection()
   {
      return this.section;
   }

   public void setSection(final NestedSectionDTO section)
   {
      this.section = section;
   }

   public NestedTicketCategoryDTO getTicketCategory()
   {
      return this.ticketCategory;
   }

   public void setTicketCategory(final NestedTicketCategoryDTO ticketCategory)
   {
      this.ticketCategory = ticketCategory;
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
