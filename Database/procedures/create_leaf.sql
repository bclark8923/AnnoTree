-- --------------------------------------------------------------------------------
-- create_leaf
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_leaf`;
DELIMITER $$


CREATE Procedure `create_leaf`(
  in name VARCHAR(45),
  in `comment` VARCHAR(1024),
  in owner_user_id INT,
  in b_id INT
  )
BEGIN
IF (select id from user where id = owner_user_id and active = true) and (select id from branch where id = b_id) then
insert into `annotree`.`leaf` 
  (name, `comment`, owner_user_id, branch_id)
  values (name, `comment`, owner_user_id, b_id);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_leaf`
  (user_id, leaf_id)
values
  (owner_user_id, @id);
-- TODO improve this
select 'id', 'name', 'comment', 'owner_user_id', 'branch_id', 'created_at' 
union 
select * from leaf where id = @id;
END IF;
END $$
delimiter ; $$
