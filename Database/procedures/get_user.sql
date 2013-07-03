-- --------------------------------------------------------------------------------
-- get_user
-- returns the information for an individual user
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_user`;
DELIMITER $$

CREATE procedure `get_user`(
  e VARCHAR(255))
BEGIN
select 'id', 'first_name',  'last_name', 'email', 'lang', 'time_zone', 'profile_image_path', 'created_at', 'status'
union
select id, first_name,  last_name, email, lang, time_zone, profile_image_path, created_at, status
            from user 
            where email = e;
END $$
delimiter ; $$
