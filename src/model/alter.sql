-- 2014-08-28 17:36
ALTER TABLE `crashes`
ADD `device` varchar(36) NOT NULL COMMENT '设备' AFTER `port`,
DROP `acc_id`,
DROP `uid`,
DROP `stacktrace`,
COMMENT='';

-- end
