-- --------------------------------------------------------------------------------
-- login_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_user`;
DELIMITER $$

CREATE procedure `get_user`(
  e VARCHAR(255))
BEGIN
DECLARE user_data varchar(1024) default '0';
select 'id', 'password', 'first_name',  'last_name', 'email', 'lang', 'time_zone', 'profile_image_path'
union
select id, password, first_name,  last_name, email, lang, time_zone, profile_image_path
            from user 
            where email = e;
END $$
delimiter ; $$
