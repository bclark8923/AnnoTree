-- --------------------------------------------------------------------------------
-- create_forest
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_forest`;
DELIMITER $$


CREATE Procedure `create_forest`(
  in user INT,
  in n varchar(45),
  in d varchar(1024)
  )
BEGIN
IF (select id from user where id = user and active = true) then
insert into `annotree`.`forest` 
  (name, description)
  values (n, d);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_forest`
  (user_id, forest_id)
values
  (user, @id);
select 'id', 'name', 'description' union select @id, n, d;
ELSE
SELECT '1';
END IF;
END $$
delimiter ; $$
