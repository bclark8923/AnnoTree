-- --------------------------------------------------------------------------------
-- create_user
-- Note: You need to salt the password in perl.
-- returns 0 - success, 1 - emails fails regex, 2 - email already exists
-- --------------------------------------------------------------------------------
drop procedure IF EXISTS `create_user`;
DELIMITER $$


CREATE procedure `create_user`(
  password VARCHAR(128), 
  first_name VARCHAR(45),
  last_name VARCHAR(45),
  email VARCHAR(255),
  lang VARCHAR(3),
  time_zone VARCHAR(15),
  profile_image_path VARCHAR(45),
  status INTEGER
)
BEGIN
If (select id from user where email = user.email) then
select '2'; 
elseIF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
insert into `annotree`.`user`
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, status) 
values 
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, status);
set @id = LAST_INSERT_ID();
select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
union
select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where id = @id;
ELSE
select '1';
END IF;
END $$
delimiter ; $$
