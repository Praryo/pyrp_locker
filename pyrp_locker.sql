SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('locker',	'Locker',	0);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('locker',	'Locker',	0);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('locker',	'Locker',	0);

DROP TABLE IF EXISTS `pyrp_locker`;
CREATE TABLE `pyrp_locker` (
  `identifier` varchar(50) NOT NULL,
  `lockerName` varchar(50) NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

