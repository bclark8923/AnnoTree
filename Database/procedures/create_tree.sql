-- --------------------------------------------------------------------------------
-- create_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  function IF EXISTS `create_tree`;
DELIMITER $$


CREATE FUNCTION `create_tree`(
  user INT,
  f_id INT,
  n varchar(45),
  d varchar(1024)
  )
RETURNS int
BEGIN

IF (select id from user where id = user) then
insert into `annotree`.`tree` 
  (name, description)
  values (n, d, f_id);
set @id = LAST_INSERT_ID();
insert into `annotree`.`user_tree`
  (user_id, tree_id)
values
  (user, @id);
return 0;
ELSE
return 1;
END IF;
END $$
delimiter ; $$
