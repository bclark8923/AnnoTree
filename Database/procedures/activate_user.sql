use annotree;

-- --------------------------------------------------------------------------------
-- activate_user 
-- return 0 on activate -1 on failure
-- --------------------------------------------------------------------------------
drop procedure if exists 'activate_user';

DELIMITER $$
CREATE procedure `activate_user`(
  e VARCHAR(255)) RETURNS INT
BEGIN
update user set active = true where email = e;
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'active' 
union
select * from user where e = email;
END $$
delimiter ; $$
