use annotree;

-- --------------------------------------------------------------------------------
-- delete_user 
-- return 0 on delete -1 on failure
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `delete_user`;
DELIMITER $$

CREATE PROCEDURE `delete_user`(
  id INT)
BEGIN
update user set status = 0 where user.id = id;
if ROW_COUNT() = 1 then
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'active' 
union
select * from user where user.id = id;
else
select '1';
end if;
END $$
delimiter ; $$
