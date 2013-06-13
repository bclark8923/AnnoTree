-- --------------------------------------------------------------------------------
-- create_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION `create_user`(
  username VARCHAR(45),
  password VARCHAR(40), 
  first_name VARCHAR(45),
  last_name VARCHAR(45),
  email VARCHAR(255),
  lang VARCHAR(3),
  time_zone VARCHAR(15),
  profile_image_path VARCHAR(45))
RETURNS int
BEGIN
IF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
insert into `annotree`.`user`
  (username, password, first_name, last_name, email, lang, time_zone, profile_image_path) 
values 
  (username, password, first_name, last_name, email, lang, time_zone, profile_image_path);
return 1;
ELSE
return 0;
END IF;
END
