-- --------------------------------------------------------------------------------
-- delete_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_annotation`;
DELIMITER $$


CREATE Procedure `delete_annotation`(
  in id INT
  )
BEGIN
update annotation set active = 0 where annotation.id = id;
END $$
delimiter ; $$
