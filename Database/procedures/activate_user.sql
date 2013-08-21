use annotree;

-- --------------------------------------------------------------------------------
-- activate_user 
-- return 0 on activate -1 on failure
-- TODO:REMOVE THIS
-- --------------------------------------------------------------------------------
drop procedure if exists `activate_user`;

DELIMITER $$
CREATE procedure `activate_user`(
  e VARCHAR(255),
  status bit(3))
BEGIN
update user set user.status = status where email = e;
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
union
select * from user where e = email;
END $$
delimiter ; $$
