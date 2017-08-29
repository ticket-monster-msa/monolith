package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.Section;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;

public class NestedSectionDTO implements Serializable
{

   private Long id;
   private String name;
   private String description;
   private int numberOfRows;
   private int rowCapacity;
   private int capacity;

   public NestedSectionDTO()
   {
   }

   public NestedSectionDTO(final Section entity)
   {
      if (entity != null)
      {
         this.id = entity.getId();
         this.name = entity.getName();
         this.description = entity.getDescription();
         this.numberOfRows = entity.getNumberOfRows();
         this.rowCapacity = entity.getRowCapacity();
         this.capacity = entity.getCapacity();
      }
   }

   public Section fromDTO(Section entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new Section();
      }
      if (this.id != null)
      {
         TypedQuery<Section> findByIdQuery = em.createQuery(
               "SELECT DISTINCT s FROM Section s WHERE s.id = :entityId",
               Section.class);
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
      entity.setName(this.name);
      entity.setDescription(this.description);
      entity.setNumberOfRows(this.numberOfRows);
      entity.setRowCapacity(this.rowCapacity);
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

   public String getDescription()
   {
      return this.description;
   }

   public void setDescription(final String description)
   {
      this.description = description;
   }

   public int getNumberOfRows()
   {
      return this.numberOfRows;
   }

   public void setNumberOfRows(final int numberOfRows)
   {
      this.numberOfRows = numberOfRows;
   }

   public int getRowCapacity()
   {
      return this.rowCapacity;
   }

   public void setRowCapacity(final int rowCapacity)
   {
      this.rowCapacity = rowCapacity;
   }

   public int getCapacity()
   {
      return this.capacity;
   }

   public void setCapacity(final int capacity)
   {
      this.capacity = capacity;
   }
}