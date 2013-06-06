-- --------------------------------------------------------------------------------
-- create_user
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE `create_user`(
  in username VARCHAR(45),
  in password VARCHAR(40), 
  in first_name VARCHAR(45),
  in last_name VARCHAR(45),
  in email VARCHAR(255),
  in lang VARCHAR(3),
  in time_zone VARCHAR(15),
  in profile_image_path VARCHAR(45))
BEGIN
insert into `annotree`.`user`(username, password, first_name, last_name, lang, time_zone, profile_image_path) values (username, SHA1(password), first_name, last_name, lang, time_zone, profile_image_path);
END
