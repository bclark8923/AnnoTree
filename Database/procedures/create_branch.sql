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
IF (select id from user where id = user and active = true) and (select id from tree where id = t) then
insert into `annotree`.`branch` 
  (tree_id, name, description)
  values (t, n, d);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_branch`
  (user_id, branch_id)
values
  (user, @id);
select 'id', 'tree_id', 'name', 'description' union select @id, t, n, d;
END IF;
END $$
delimiter ; $$
