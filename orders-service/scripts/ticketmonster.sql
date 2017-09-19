CREATE DATABASE IF NOT EXISTS ticketmonster;
USE ticketmonster;

CREATE TABLE `section` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `number_of_rows` int(11) NOT NULL,
  `row_capacity` int(11) NOT NULL,
  `venue_id` bigint(20) DEFAULT NULL,
  `venue_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKbdpgnn9f25eootvop4cqics0i` (`name`,`venue_id`)
) ;


CREATE TABLE `appearance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) DEFAULT NULL,
  `event_name` varchar(255) DEFAULT NULL,
  `venue_id` bigint(20) DEFAULT NULL,
  `venue_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKfgr2nkyi0qpjhjvji0mdfvudc` (`event_id`,`venue_id`)
) ;

CREATE TABLE `booking` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cancellation_code` varchar(255) NOT NULL,
  `contact_email` varchar(255) NOT NULL,
  `created_on` datetime NOT NULL,
  `performance_id` bigint(20) DEFAULT NULL,
  `performance_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

CREATE TABLE `section_allocation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `allocated` longblob,
  `occupied_count` int(11) NOT NULL,
  `performance_id` bigint(20) DEFAULT NULL,
  `performance_name` varchar(255) DEFAULT NULL,
  `version` bigint(20) NOT NULL,
  `section_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKcbyh3leaebtlwfc4eiotooopq` (`performance_id`,`section_id`),
  KEY `FK3rw79cvgssmpg21ds219dydrp` (`section_id`),
  CONSTRAINT `FK3rw79cvgssmpg21ds219dydrp` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`)
) ;

CREATE TABLE `ticket_category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_hbsjuus8lw4socklmianxb00r` (`description`)
) ;

CREATE TABLE `ticket` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `price` float NOT NULL,
  `number` int(11) NOT NULL,
  `row_number` int(11) NOT NULL,
  `section_id` bigint(20) DEFAULT NULL,
  `ticket_category_id` bigint(20) NOT NULL,
  `tickets_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK43lerp18busrqen2gd43vhepi` (`section_id`),
  KEY `FKbt7yntrpp48qd82aubrq6lbx8` (`ticket_category_id`),
  KEY `FK8h02qtjhsys9q4ibyomkoctu6` (`tickets_id`),
  CONSTRAINT `FK43lerp18busrqen2gd43vhepi` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`),
  CONSTRAINT `FK8h02qtjhsys9q4ibyomkoctu6` FOREIGN KEY (`tickets_id`) REFERENCES `booking` (`id`),
  CONSTRAINT `FKbt7yntrpp48qd82aubrq6lbx8` FOREIGN KEY (`ticket_category_id`) REFERENCES `ticket_category` (`id`)
) ;

CREATE TABLE `ticket_price_guide` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `price` float NOT NULL,
  `section_id` bigint(20) NOT NULL,
  `show_id` bigint(20) NOT NULL,
  `ticketcategory_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKqgjl8uim31mh6vop6pnt188b4` (`section_id`,`show_id`,`ticketcategory_id`),
  KEY `FKt21lxux6lmhmw6jyx3schteio` (`show_id`),
  KEY `FKbdxqxoxov15nyypxdryur5fs5` (`ticketcategory_id`),
  CONSTRAINT `FK60ub03ab2r2j6d5v8v3v0dprr` FOREIGN KEY (`section_id`) REFERENCES `section` (`id`),
  CONSTRAINT `FKbdxqxoxov15nyypxdryur5fs5` FOREIGN KEY (`ticketcategory_id`) REFERENCES `ticket_category` (`id`),
  CONSTRAINT `FKt21lxux6lmhmw6jyx3schteio` FOREIGN KEY (`show_id`) REFERENCES `appearance` (`id`)
) ;



-- Section 1
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'A', 'Premier platinum reserve',20, 100, 1);
-- Section 2
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'B', 'Premier gold reserve', 20, 100, 1);
-- Section 3
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'C', 'Premier silver reserve', 30, 100, 1);
-- section 4
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'D', 'General', 40, 100, 1);

-- Venue 2
-- insert into Venue ( name, city, country, street, description, mediaitem_id, capacity) values ( 'Sydney Opera House', 'Sydney', 'Australia', 'Bennelong point', 'The Sydney Opera House is a multi-venue performing arts centre in Sydney, New South Wales, Australia' ,3, 15030);

-- Section 5
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S1', 'Front left', 50, 50, 2);
-- Section 6
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S2', 'Front centre', 50, 50, 2);
-- Section 7
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S3', 'Front right',50, 50, 2);
-- Section 8
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S4', 'Rear left', 50, 50, 2);
-- Section 9
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S5', 'Rear centre', 50, 50, 2);
-- Section 10
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S6', 'Rear right', 50, 50, 2);
-- Section 11
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'S7', 'Balcony', 1, 30, 2);

-- Venue 3
-- insert into Venue ( name, city, country, street, description, mediaitem_id, capacity) values ( 'BMO Field', 'Toronto', 'Canada', '170 Princes Boulevard','BMO Field is a Canadian soccer stadium located in Exhibition Place in the city of Toronto.',5, 30000);

-- Section 12
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'A', 'Premier platinum reserve',40, 100, 3);
-- Section 13
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'B', 'Premier gold reserve', 40, 100, 3);
-- Section 14
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'C', 'Premier silver reserve', 30, 200, 3);
-- Section 15
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'D', 'General', 80, 200, 3);

-- Venue 4

-- insert into Venue ( name, city, country, street, description, mediaitem_id, capacity) values ( 'Opera Garnier', 'Paris', 'France', '8 Rue Scribe','The Palais Garnier is a 1,979-seat opera house, which was built from 1861 to 1875 for the Paris Opera.', 23, 1972);

-- Section 16
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'A', 'Center',10, 60, 4);
-- Section 17
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'B', 'Left', 10, 41, 4);
-- Section 18
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'C', 'Right', 10, 41, 4);
-- Section 19
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'D', 'Balcony', 6, 92, 4);

-- Venue 5

-- insert into Venue ( name, city, country, street, description, mediaitem_id, capacity) values ( 'Boston Symphony Hall', 'Boston', 'USA', '301 Massachusetts Avenue','Designed by McKim, Mead and White, it was built in 1900 for the Boston Symphony Orchestra, which continues to make the hall its home. The hall was designated a U.S. National Historic Landmark in 1999.', 24, 1972);

-- Section 20
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'A', 'Center',10, 60, 5);
-- Section 21
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'B', 'Left', 10, 41, 5);
-- Section 22
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'C', 'Right', 10, 41, 5);
-- Section 23
insert into section ( name, description, number_of_rows, row_capacity, venue_id) values ( 'D', 'Balcony', 6, 92, 5);

-- TicketCategory 1
insert into ticket_category ( description) values ( 'Adult');
-- TicketCategory 2
insert into ticket_category ( description) values ( 'Child 0-14yrs');


-- Show 1
insert into appearance ( event_id, venue_id) values ( 1, 1);

-- Performance 1
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (1, 1, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (1, 2, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (1, 3, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (1, 4, null, 0, 1);

-- Performance 2
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (2, 1, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (2, 2, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (2, 3, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (2, 4, null, 0, 1);

-- Show 2
insert into appearance ( event_id, venue_id) values ( 1, 2);

-- Performance 3
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 5, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 6, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 7, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 8, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 9, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 10, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (3, 11, null, 0, 1);

-- Performance #4
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 5, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 6, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 7, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 8, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 9, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 10, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (4, 11, null, 0, 1);

-- Show 3
insert into appearance ( event_id, venue_id) values ( 2, 1);

-- Performance 5
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (5, 1, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (5, 2, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (5, 3, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (5, 4, null, 0, 1);

-- Performance 6

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (6, 1, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (6, 2, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (6, 3, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (6, 4, null, 0, 1);

-- Show 4
insert into appearance ( event_id, venue_id) values ( 2, 2);

-- Performance 7

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 5, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 6, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 7, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 8, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 9, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 10, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (7, 11, null, 0, 1);

-- Performance 8

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 5, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 6, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 7, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 8, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 9, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 10, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (8, 11, null, 0, 1);

-- show 5
insert into appearance ( event_id, venue_id) values ( 3, 3);

-- Performance 9

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (9, 12, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (9, 13, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (9, 14, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (9, 15, null, 0, 1);

-- Show 6
insert into appearance ( event_id, venue_id) values ( 1, 5);

-- Performance 10

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (10, 20, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (10, 21, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (10, 22, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (10, 23, null, 0, 1);

-- Performance 11

insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (11, 20, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (11, 21, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (11, 22, null, 0, 1);
insert into section_allocation(performance_id, section_id, allocated, occupied_count, version) values (11, 23, null, 0, 1);




insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (1, 1, 1, 219.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (1, 2, 1, 199.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (1, 3, 1, 179.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (1, 4, 1, 149.50);

insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 5, 1, 167.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 6, 1, 197.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 7, 1, 167.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 8, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 9, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 10, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 11, 1, 122.5);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 5, 2, 157.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 6, 2, 187.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 7, 2, 157.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 8, 2, 145.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 9, 2, 145.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 10, 2, 145.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (2, 11, 2, 112.5);


insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (3, 1, 1, 219.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (3, 2, 1, 199.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (3, 3, 1, 179.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (3, 4, 1, 149.50);

insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 5, 1, 167.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 6, 1, 197.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 7, 1, 167.75);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 8, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 9, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 10, 1, 155.0);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (4, 11, 1, 122.5);

insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (5, 12, 1, 219.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (5, 13, 1, 199.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (5, 14, 1, 179.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (5, 15, 1, 149.50);

insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (6, 20, 1, 219.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (6, 21, 1, 199.50);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (6, 22, 1, 110);
insert into ticket_price_guide ( show_id, section_id, ticketcategory_id, price) values (6, 23, 1, 55);
