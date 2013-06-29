-- --------------------------------------------------------------------------------
-- create_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_annotation`;
DELIMITER $$


CREATE Procedure `create_annotation`(
  in mime_type VARCHAR(128),
  in path VARCHAR(1024),
  in filename VARCHAR(128),
  in leaf_id INT
)
BEGIN
IF (select id from leaf where id = leaf_id) THEN
    insert into annotation(mime_type, path, filename, leaf_id) values (mime_type, path, filename, leaf_id);
    set @id = LAST_INSERT_ID();
    select 'id', 'mime_type', 'path', 'filename', 'leaf_id', 'created_at'
    union
    select id, mime_type, path, filename, leaf_id, created_at
    from annotation
    where id = @id;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
