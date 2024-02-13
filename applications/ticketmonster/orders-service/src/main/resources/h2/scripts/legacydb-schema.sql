DROP TABLE IF EXISTS MediaItem;
DROP TABLE IF EXISTS EventCategory;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Venue;
DROP TABLE IF EXISTS Appearance;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS SectionAllocation;
DROP TABLE IF EXISTS TicketCategory;
DROP TABLE IF EXISTS TicketPrice;
DROP TABLE IF EXISTS Ticket;


CREATE TABLE `MediaItem` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `mediaType` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_4hr5wsvx6wqc3x7f62hi4icwk` (`url`)
) ;

CREATE TABLE `EventCategory` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_pcd6hbptlq9jx8t5l135k2mev` (`description`)
) ;


CREATE TABLE `Event` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(1000) NOT NULL,
  `name` varchar(50) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `mediaItem_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_ij7n685n8qbung3jvhw3rifm7` (`name`),
  KEY `FK8csjtmgirbl21kpwsxo6x66nh` (`category_id`),
  KEY `FK6nof7ckcmem31bk5t3poa9nnf` (`mediaItem_id`),
  CONSTRAINT `FK6nof7ckcmem31bk5t3poa9nnf` FOREIGN KEY (`mediaItem_id`) REFERENCES `MediaItem` (`id`),
  CONSTRAINT `FK8csjtmgirbl21kpwsxo6x66nh` FOREIGN KEY (`category_id`) REFERENCES `EventCategory` (`id`)
) ;


CREATE TABLE `Venue` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `mediaItem_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_k049njfy1fdk2svm5m54ulorx` (`name`),
  KEY `FKn88gt1fcwaa14l0r0p41vh2nr` (`mediaItem_id`),
  CONSTRAINT `FKn88gt1fcwaa14l0r0p41vh2nr` FOREIGN KEY (`mediaItem_id`) REFERENCES `MediaItem` (`id`)
) ;


CREATE TABLE `Appearance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) NOT NULL,
  `venue_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKb2ol0eoqtadvfoxhsnqcajgqa` (`event_id`,`venue_id`),
  KEY `FK43wxxxwigwlxjucwsyg4e7t4p` (`venue_id`),
  CONSTRAINT `FK43wxxxwigwlxjucwsyg4e7t4p` FOREIGN KEY (`venue_id`) REFERENCES `Venue` (`id`),
  CONSTRAINT `FKl28e6wqudihnxsyqhmj9jdepw` FOREIGN KEY (`event_id`) REFERENCES `Event` (`id`)
) ;

CREATE TABLE `Performance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `show_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKo9uuea91geqwv8cnwi1uq625w` (`date`,`show_id`),
  KEY `FKfyal296q9uqmwdtgchsblvt79` (`show_id`),
  CONSTRAINT `FKfyal296q9uqmwdtgchsblvt79` FOREIGN KEY (`show_id`) REFERENCES `Appearance` (`id`)
) ;

CREATE TABLE `Section` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `numberOfRows` int(11) NOT NULL,
  `rowCapacity` int(11) NOT NULL,
  `venue_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKruosqireipse41rdsuvhqj050` (`name`,`venue_id`),
  KEY `FKjspvs4wkh7pcqfpfler1vgvwh` (`venue_id`),
  CONSTRAINT `FKjspvs4wkh7pcqfpfler1vgvwh` FOREIGN KEY (`venue_id`) REFERENCES `Venue` (`id`)
) ;


CREATE TABLE `Booking` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cancellationCode` varchar(255) NOT NULL,
  `contactEmail` varchar(255) NOT NULL,
  `createdOn` datetime NOT NULL,
  `performance_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKedg6lddbdlf8nsk7jrxvq4s48` (`performance_id`),
  CONSTRAINT `FKedg6lddbdlf8nsk7jrxvq4s48` FOREIGN KEY (`performance_id`) REFERENCES `Performance` (`id`)
) ;

CREATE TABLE `SectionAllocation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `allocated` longblob,
  `occupiedCount` int(11) NOT NULL,
  `version` bigint(20) NOT NULL,
  `performance_id` bigint(20) NOT NULL,
  `section_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK25wlm457x8dmc00we5uw7an3s` (`performance_id`,`section_id`),
  KEY `FK60388cvbhb1xyrdhhe546t6dl` (`section_id`),
  CONSTRAINT `FK60388cvbhb1xyrdhhe546t6dl` FOREIGN KEY (`section_id`) REFERENCES `Section` (`id`),
  CONSTRAINT `FKa9q2pu832scr9n9be1tkgex34` FOREIGN KEY (`performance_id`) REFERENCES `Performance` (`id`)
)  ;

CREATE TABLE `TicketCategory` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_43455ipnchbn6r4bg8pviai3g` (`description`)
) ;


CREATE TABLE `TicketPrice` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `price` float NOT NULL,
  `section_id` bigint(20) NOT NULL,
  `show_id` bigint(20) NOT NULL,
  `ticketCategory_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6v6we3djkskvbac7e9ctbylap` (`section_id`,`show_id`,`ticketCategory_id`),
  KEY `FKslfwrt774iadqwitd7d8l97vg` (`show_id`),
  KEY `FKcuvr00xp47bs81u95aq2amomn` (`ticketCategory_id`),
  CONSTRAINT `FKa4etyq878vwpxp4rhwkg65rgt` FOREIGN KEY (`section_id`) REFERENCES `Section` (`id`),
  CONSTRAINT `FKcuvr00xp47bs81u95aq2amomn` FOREIGN KEY (`ticketCategory_id`) REFERENCES `TicketCategory` (`id`),
  CONSTRAINT `FKslfwrt774iadqwitd7d8l97vg` FOREIGN KEY (`show_id`) REFERENCES `Appearance` (`id`)
)  ;

CREATE TABLE `Ticket` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `price` float NOT NULL,
  `number` int(11) NOT NULL,
  `rowNumber` int(11) NOT NULL,
  `section_id` bigint(20) DEFAULT NULL,
  `ticketCategory_id` bigint(20) NOT NULL,
  `tickets_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK7xoel6i5b4nrphore8ns2jtld` (`section_id`),
  KEY `FK88jejylfnpfqcslai19n4naqf` (`ticketCategory_id`),
  KEY `FKolbt9u28gyshci6ek9ep0rl5d` (`tickets_id`),
  CONSTRAINT `FK7xoel6i5b4nrphore8ns2jtld` FOREIGN KEY (`section_id`) REFERENCES `Section` (`id`),
  CONSTRAINT `FK88jejylfnpfqcslai19n4naqf` FOREIGN KEY (`ticketCategory_id`) REFERENCES `TicketCategory` (`id`),
  CONSTRAINT `FKolbt9u28gyshci6ek9ep0rl5d` FOREIGN KEY (`tickets_id`) REFERENCES `Booking` (`id`)
)  ;

