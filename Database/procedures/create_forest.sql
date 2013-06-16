-- --------------------------------------------------------------------------------
-- create_forest
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  function IF EXISTS `create_forest`;
DELIMITER $$


CREATE FUNCTION `create_forest`(
  user INT,
  n varchar(45),
  d varchar(1024)
  )
RETURNS int
BEGIN
IF (select id from user where id = user) then
-- AND (select f_id from forest where f_id = id) then
insert into `annotree`.`forest` 
  (name, description)
  values (n, d);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_forest`
  (user_id, forest_id)
values
  (user, @id);
return 0;
ELSE
return 1;
END IF;
END $$
delimiter ; $$
