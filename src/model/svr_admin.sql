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


DROP TABLE IF EXISTS `histories`;
CREATE TABLE `histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `who` varchar(36) NOT NULL COMMENT '谁',
  `what` tinyint(1) NOT NULL COMMENT '干了什么',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '什么时候',
  PRIMARY KEY (`id`),
  KEY `account_id` (`who`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 2014-08-12 06:10:43
