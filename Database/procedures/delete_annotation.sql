-- --------------------------------------------------------------------------------
-- delete_annotation
-- returns ??
-- TODO: add check
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_annotation`;
DELIMITER $$


CREATE Procedure `delete_annotation`(
  in id INT
  )
BEGIN
delete from annotation where annotation.id = id;
END $$
delimiter ; $$
