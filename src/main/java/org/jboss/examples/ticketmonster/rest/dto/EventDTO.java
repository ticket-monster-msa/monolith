package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.Event;
import javax.persistence.EntityManager;
import org.jboss.examples.ticketmonster.rest.dto.NestedMediaItemDTO;
import org.jboss.examples.ticketmonster.rest.dto.NestedEventCategoryDTO;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class EventDTO implements Serializable
{

   private Long id;
   private String name;
   private NestedMediaItemDTO mediaItem;
   private NestedEventCategoryDTO category;
   private String description;

   public EventDTO()
   {
   }

   public EventDTO(final Event entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.name = entity.getName();
         this.mediaItem = new NestedMediaItemDTO(entity.getMediaItem());
         this.category = new NestedEventCategoryDTO(entity.getCategory());
         this.description = entity.getDescription();
      }
   }

   public Event fromDTO(Event entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new Event();
      }
      entity.setName(this.name);
      if (this.mediaItem != null)
      {
         entity.setMediaItem(this.mediaItem.fromDTO(entity.getMediaItem(),
               em));
      }
      if (this.category != null)
      {
         entity.setCategory(this.category.fromDTO(entity.getCategory(), em));
      }
      entity.setDescription(this.description);
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

   public String getName()
   {
      return this.name;
   }

   public void setName(final String name)
   {
      this.name = name;
   }

   public NestedMediaItemDTO getMediaItem()
   {
      return this.mediaItem;
   }

   public void setMediaItem(final NestedMediaItemDTO mediaItem)
   {
      this.mediaItem = mediaItem;
   }

   public NestedEventCategoryDTO getCategory()
   {
      return this.category;
   }

   public void setCategory(final NestedEventCategoryDTO category)
   {
      this.category = category;
   }

   public String getDescription()
   {
      return this.description;
   }

   public void setDescription(final String description)
   {
      this.description = description;
   }
}