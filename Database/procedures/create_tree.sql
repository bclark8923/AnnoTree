-- --------------------------------------------------------------------------------
-- create_tree
-- returns 
-- created tree on success
-- 1 if user does not exist or is deleted
-- 2 if forest does not exist
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_tree`;
DELIMITER $$


CREATE Procedure `create_tree`(
  in u INT,
  in f INT,
  in n varchar(45),
  in d varchar(1024),
  in l varchar(1024)
  )
BEGIN
IF (select id from user where id = u) THEN
    IF (select id from forest where id = f) THEN
        IF (select id from user_forest where user_id = u and forest_id = f) THEN
            insert into `annotree`.`tree` 
              (forest_id, name, description, logo, owner_id)
              values (f, n, d, l, u);
            set @id = LAST_INSERT_ID();
            insert into `annotree`.`user_tree`
              (user_id, tree_id)
            values
              (u, @id);
            select 'id', 'forest_id', 'name', 'description', 'created_at', 'logo' 
            union 
            select id, forest_id, name, description, created_at, logo
            from tree
            where
            id = @id;
        ELSE
            select '3';
        END IF;
    ELSE
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
