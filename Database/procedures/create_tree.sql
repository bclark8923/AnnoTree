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
  in l varchar(1024),
  IN token_in varchar(64),
  IN created_in TIMESTAMP
  )
BEGIN
--TODO: Change inserts into one insert with select statement.
IF (select id from user where id = u) THEN
    IF (select id from forest where id = f) THEN
        IF (select id from user_forest where user_id = u and forest_id = f) THEN
            insert into `annotree`.`tree` 
              (forest_id, name, description, logo, owner_id, token, created_at)
              values (f, n, d, l, u, token_in, created_in);
            set @tree_id = LAST_INSERT_ID();
            SET @forest_owner = (SELECT f.owner_id 
                FROM forest AS f INNER JOIN tree AS t ON t.forest_id = f.id
                WHERE t.id = @tree_id);
            IF (@forest_owner != u AND @forest_owner IS NOT NULL) THEN
                INSERT INTO user_tree (user_id, tree_id)
                    VALUES (@forest_owner, @tree_id);
            END IF;
            insert into `annotree`.`user_tree` (user_id, tree_id)
                values (u, @tree_id);
            select 'id', 'forest_id', 'name', 'description', 'created_at', 'logo', 'token' 
            union 
            select id, forest_id, name, description, created_at, logo, token
            from tree
            where
            id = @tree_id;
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
