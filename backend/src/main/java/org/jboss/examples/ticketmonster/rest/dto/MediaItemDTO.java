package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.MediaItem;
import javax.persistence.EntityManager;
import org.jboss.examples.ticketmonster.model.MediaType;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class MediaItemDTO implements Serializable
{

   private Long id;
   private MediaType mediaType;
   private String url;

   public MediaItemDTO()
   {
   }

   public MediaItemDTO(final MediaItem entity)
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