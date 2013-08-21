-- --------------------------------------------------------------------------------
-- create_annotation_with_owner
-- returns ??
-- TODO: merge with create_annotation
-- Have null owner_email set null in database
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_annotation_with_owner`;
DELIMITER $$


CREATE Procedure `create_annotation_with_owner`(
    IN mime_type VARCHAR(128),
    IN path_in VARCHAR(1024),
    IN filename VARCHAR(128),
    IN leaf_id_in INT,
    IN meta_sys_in VARCHAR(128),
    IN meta_ver_in VARCHAR(128),
    IN meta_model_in VARCHAR(128),
    IN meta_vendor_in VARCHAR(128),
    IN meta_or_in VARCHAR(128),
    IN owner_email VARCHAR(255),
    IN site_url_in VARCHAR(255)
)
BEGIN
DECLARE dir VARCHAR(16);
DECLARE ownerid INT;
SELECT id INTO ownerid FROM user WHERE email = owner_email;
IF (select id from leaf where id = leaf_id_in) THEN
    INSERT INTO annotation (mime_type, filename, leaf_id, meta_system, meta_version, meta_model, meta_vendor, meta_orientation, created_by, site_url) 
        VALUES (mime_type, filename, leaf_id_in, meta_sys_in, meta_ver_in, meta_model_in, meta_vendor_in, meta_or_in, ownerid, site_url_in);
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
    select 'id', 'mime_type', 'path', 'filename', 'leaf_id', 'created_at', 'filename_disk', 'meta_system', 'meta_version', 'meta_model', 'meta_vendor', 'meta_orientation'
    union
    select id, mime_type, path, filename, leaf_id, created_at, filename_disk, meta_system, meta_version, meta_model, meta_vendor, meta_orientation
    from annotation
    where id = @id;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
