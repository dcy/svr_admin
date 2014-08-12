-- Adminer 4.1.0 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(36) NOT NULL COMMENT '用户名',
  `password` varchar(36) NOT NULL COMMENT '密码',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `accounts` (`id`, `name`, `password`) VALUES
(4,	'dcy',	'dcydcy');

DROP TABLE IF EXISTS `histories`;
CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL COMMENT '谁',
  `what` tinyint(1) NOT NULL COMMENT '干了什么',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '什么时候',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `histories` (`id`, `account_id`, `what`, `time`) VALUES
(1,	4,	1,	'2014-08-11 09:37:26'),
(2,	4,	1,	'2014-08-11 09:51:11'),
(3,	4,	1,	'2014-08-11 10:02:09'),
(4,	4,	1,	'2014-08-11 10:06:02'),
(5,	4,	1,	'2014-08-11 10:08:08'),
(6,	4,	1,	'2014-08-11 10:09:09'),
(7,	4,	1,	'2014-08-11 10:12:52'),
(8,	4,	1,	'2014-08-11 12:10:03'),
(9,	4,	2,	'2014-08-11 12:10:10'),
(10,	4,	1,	'2014-08-11 12:10:37'),
(11,	4,	1,	'2014-08-11 12:11:07'),
(12,	4,	2,	'2014-08-11 12:11:13'),
(13,	4,	2,	'2014-08-11 12:12:02'),
(14,	4,	1,	'2014-08-11 12:12:14'),
(15,	4,	1,	'2014-08-11 13:07:34');

-- 2014-08-11 13:10:02
