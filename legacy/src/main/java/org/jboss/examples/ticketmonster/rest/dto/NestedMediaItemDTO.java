package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.MediaItem;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;
import org.jboss.examples.ticketmonster.model.MediaType;

public class NestedMediaItemDTO implements Serializable
{

   private Long id;
   private MediaType mediaType;
   private String url;

   public NestedMediaItemDTO()
   {
   }

   public NestedMediaItemDTO(final MediaItem entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.mediaType = entity.getMediaType();
         this.url = entity.getUrl();
      }
   }

   public MediaItem fromDTO(MediaItem entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new MediaItem();
      }
      if (this.id != null)
      {
         TypedQuery<MediaItem> findByIdQuery = em
               .createQuery(
                     "SELECT DISTINCT m FROM MediaItem m WHERE m.id = :entityId",
                     MediaItem.class);
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
      entity.setMediaType(this.mediaType);
      entity.setUrl(this.url);
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

   public MediaType getMediaType()
   {
      return this.mediaType;
   }

   public void setMediaType(final MediaType mediaType)
   {
      this.mediaType = mediaType;
   }

   public String getUrl()
   {
      return this.url;
   }

   public void setUrl(final String url)
   {
      this.url = url;
   }
}