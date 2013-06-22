use annotree;

-- --------------------------------------------------------------------------------
-- delete_user 
-- return 0 on delete -1 on failure
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `delete_user`;
DELIMITER $$

CREATE PROCEDURE `delete_user`(
  e VARCHAR(255))
BEGIN
if (select id from user where email = e) then
update user set active = false where email = e;
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'active' 
union
select * from user where email = e;
else
select '1';
end if;
END $$
delimiter ; $$
