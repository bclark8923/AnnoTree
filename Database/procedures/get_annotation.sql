-- --------------------------------------------------------------------------------
-- get_annotation
-- returns ??
-- TODO:should there be a check?
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_annotation`;
DELIMITER $$


CREATE Procedure `get_annotation`(
  in leaf_id INT
  )
BEGIN
select 'id', 'mime_type', 'path', 'filename', 'leaf_id', 'created_at'
union
select id, mime_type, path, filename, leaf_id, created_at from annotation as a where a.leaf_id = leaf_id;
END $$
delimiter ; $$
