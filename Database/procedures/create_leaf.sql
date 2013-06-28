-- --------------------------------------------------------------------------------
-- create_leaf
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_leaf`;
DELIMITER $$


CREATE Procedure `create_leaf`(
  in n VARCHAR(45),
  in d VARCHAR(1024),
  in owner_user_id INT,
  in b_id INT
  )
BEGIN
IF (select id from user where id = owner_user_id and active = true) THEN
    IF (select id from branch where id = b_id) THEN
        insert into `annotree`.`leaf` 
          (name, description, owner_user_id, branch_id)
          values (n, d, owner_user_id, b_id);
        set @id = LAST_INSERT_ID();
        insert into `annotree`.`user_leaf`
          (user_id, leaf_id)
        values
          (owner_user_id, @id);
        -- TODO improve this
        select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at'
        union 
        select id, name, description, owner_user_id, branch_id, created_at 
        from leaf 
        where id = @id;
    ELSE 
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
