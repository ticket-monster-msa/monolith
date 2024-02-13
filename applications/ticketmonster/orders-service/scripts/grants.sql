CREATE DATABASE IF NOT EXISTS orders;
CREATE DATABASE IF NOT EXISTS ticketmonster;

GRANT ALL PRIVILEGES ON `ticketmonster`.* TO 'ticket'@'%';
GRANT ALL PRIVILEGES ON `orders`.* TO 'ticket'@'%';