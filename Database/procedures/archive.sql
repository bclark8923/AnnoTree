-- --------------------------------------------------------------------------------
-- archive
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `archive`;
DELIMITER $$

CREATE Procedure `archive`()
BEGIN
start transaction;
insert into `archive`.`forest`
select * from `annotree`.`forest` where active = 0;
delete `annotree`.`forest` where active = 0;
commit;

start transaction;
insert into `archive`.`tree`
select * from `annotree`.`tree` where `annotree`.`tree`.active = 0;
delete `annotree`.`tree` where active = 0;
commit;


start transaction;
insert into `archive`.`leaf`
select * from `annotree`.`leaf` where `annotree`.`leaf`.active = 0;
delete `annotree`.`leaf` where active = 0;
commit;

start transaction;
insert into `archive`.`annotation`
select * from `annotree`.`annotation` where `annotree`.`annotation`.active = 0;
delete `annotree`.`annotation` where active = 0;
commit;

END $$
