-- --------------------------------------------------------------------------------
-- get_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_annotation`;
DELIMITER $$


CREATE Procedure `get_annotation`(
  in leaf_id INT
  )
BEGIN
select 'id', 'mime_type', 'path', 'leaf_id', 'created_at'
union
select * from annotation as a where a.leaf_id = leaf_id ;
END $$
delimiter ; $$
