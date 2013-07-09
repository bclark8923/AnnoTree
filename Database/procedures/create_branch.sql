-- --------------------------------------------------------------------------------
-- create_branch
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_branch`;
DELIMITER $$


CREATE Procedure `create_branch`(
  in user INT,
  in t INT,
  in n varchar(45),
  in d varchar(1024)
  )
BEGIN
IF (select id from user where id = user) then
    IF (select id from tree where id = t) then
        insert into `annotree`.`branch` 
          (tree_id, name, description)
          values (t, n, d);
        set @id = LAST_INSERT_ID();
        select 'id', 'tree_id', 'name', 'description', 'created_at' 
        union 
        select id, tree_id, name, description, created_at
        from `annotree`.`branch`
        where id = @id;
    ELSE
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
