-- --------------------------------------------------------------------------------
-- create_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_annotation`;
DELIMITER $$


CREATE Procedure `create_annotation`(
  in mime_type VARCHAR(45),
  in path VARCHAR(1024),
  in leaf_id INT
  )
BEGIN
insert into annotation(mime_type, path, leaf_id) values (mime_type, path, leaf_id);
END $$
delimiter ; $$
