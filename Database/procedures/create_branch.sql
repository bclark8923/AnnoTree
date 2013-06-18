-- --------------------------------------------------------------------------------
-- create_branch
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_branch`;
DELIMITER $$


CREATE Procedure `create_branch`(
  in user INT,
  in f INT,
  in n varchar(45),
  in d varchar(1024)
  )
BEGIN
IF (select id from user where id = user and active = true) and (select id from forest where id = f) then
insert into `annotree`.`branch` 
  (forest_id, name, description)
  values (f, n, d);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_branch`
  (user_id, branch_id)
values
  (user, @id);
select 'id', 'forest_id', 'name', 'description' union select @id, f, n, d;
END IF;
END $$
delimiter ; $$
