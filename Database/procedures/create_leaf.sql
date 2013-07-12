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
IF (select id from user where id = owner_user_id) THEN
    IF (select id from branch where id = b_id) THEN
        insert into `annotree`.`leaf` 
          (name, description, owner_user_id, branch_id)
          values (n, d, owner_user_id, b_id);
        set @leaf_id = LAST_INSERT_ID();
        -- TODO improve this
        select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at'
        union 
        select id, name, description, owner_user_id, branch_id, created_at 
        from leaf 
        where id = @leaf_id;
    ELSE 
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
