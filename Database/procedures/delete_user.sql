use annotree;

-- --------------------------------------------------------------------------------
-- delete_user 
-- return 0 on delete -1 on failure
-- --------------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS 'delete_user';

CREATE PROCEDURE `delete_user`(
  e VARCHAR(255)) RETURNS INT
BEGIN
update user set active = false where email = e;
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'active' 
union
select * from user where email = e;
END $$
delimiter ; $$
