-- --------------------------------------------------------------------------------
-- create_user
-- Note: You need to salt the password in perl.
-- returns 0 - success, 1 - emails fails regex, 2 - email already exists
-- --------------------------------------------------------------------------------
drop  function IF EXISTS `create_user`;
DELIMITER $$


CREATE FUNCTION `create_user`(
  password VARCHAR(40), 
  first_name VARCHAR(45),
  last_name VARCHAR(45),
  email VARCHAR(255),
  lang VARCHAR(3),
  time_zone VARCHAR(15),
  profile_image_path VARCHAR(45))
RETURNS int
BEGIN
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' return 2;

IF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
insert into `annotree`.`user`
  (password, first_name, last_name, email, lang, time_zone, profile_image_path) 
values 
  (password, first_name, last_name, email, lang, time_zone, profile_image_path);
return 0;
ELSE
return 1;
END IF;
END $$
delimiter ; $$
