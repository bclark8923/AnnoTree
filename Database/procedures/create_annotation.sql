-- --------------------------------------------------------------------------------
-- create_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_annotation`;
DELIMITER $$


CREATE Procedure `create_annotation`(
  in mime_type VARCHAR(128),
  in path_in VARCHAR(1024),
  in filename VARCHAR(128),
  in leaf_id_in INT
)
BEGIN
DECLARE dir VARCHAR(16);
IF (select id from leaf where id = leaf_id_in) THEN
    insert into annotation(mime_type, filename, leaf_id) values (mime_type, filename, leaf_id_in);
    SET @id = LAST_INSERT_ID();
    IF (filename = 'anno_default.png') THEN
        UPDATE annotation SET path = concat(path_in, @id),
            filename_disk = 'anno_default.png'
            WHERE id = @id;
    ELSE 
        select concat(t.forest_id, '/', b.tree_id, '/', b.id, '/') INTO dir
            FROM tree AS t INNER JOIN branch AS b ON t.id = b.tree_id
            INNER JOIN leaf AS l on l.branch_id = b.id
            WHERE l.id = leaf_id_in;
        UPDATE annotation SET path = concat(path_in, @id),
            filename_disk = concat(dir, @id, '_', filename)
            WHERE id = @id;
    END IF;
    select 'id', 'mime_type', 'path', 'filename', 'leaf_id', 'created_at', 'filename_disk'
    union
    select id, mime_type, path, filename, leaf_id, created_at, filename_disk
    from annotation
    where id = @id;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
