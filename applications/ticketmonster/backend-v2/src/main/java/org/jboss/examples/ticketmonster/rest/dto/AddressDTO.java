package org.jboss.examples.ticketmonster.rest.dto;

import java.io.Serializable;
import org.jboss.examples.ticketmonster.model.Address;
import javax.persistence.EntityManager;

public class AddressDTO implements Serializable
{

   private String street;
   private String city;
   private String country;

   public AddressDTO()
   {
   }

   public AddressDTO(final Address entity)
   {
      if (entity != null)
      {
         this.street = entity.getStreet();
         this.city = entity.getCity();
         this.country = entity.getCountry();
      }
   }

   public Address fromDTO(Address entity, EntityManager em)
   {
      if (entity == null)
      {
         entity = new Address();
      }
      entity.setStreet(this.street);
      entity.setCity(this.city);
      entity.setCountry(this.country);
      return entity;
   }

   public String getStreet()
   {
      return this.street;
   }

   public void setStreet(final String street)
   {
      this.street = street;
   }

   public String getCity()
   {
      return this.city;
   }

   public void setCity(final String city)
   {
      this.city = city;
   }

   public String getCountry()
   {
      return this.country;
   }

   public void setCountry(final String country)
   {
      this.country = country;
   }
}