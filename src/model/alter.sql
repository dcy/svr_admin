-- 2014-08-27 11:30
ALTER TABLE `crashes`
ADD `dump` varchar(160) COLLATE 'utf8_general_ci' NOT NULL COMMENT 'dump' AFTER `stacktrace`,
COMMENT='';
-- end
