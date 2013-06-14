-- --------------------------------------------------------------------------------
-- login_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
use annotre;
drop function `get_user`;
DELIMITER $$

CREATE FUNCTION `get_user`(
  e VARCHAR(255))
returns VARCHAR(1024)
BEGIN
DECLARE user_data varchar(1024) default '0';
SET @user_data = (select concat(id, ', ',
                                      password, ', ', 
                                      first_name, ', ',
                                      last_name, ', ',
                                      email, ', ',
                                      IFNULL(lang, ''), ', ',
                                      IFNULL(time_zone, ''), ', ',
                                      IFNULL(profile_image_path, ''))
            from user 
            where email = e);
return @user_data;
END $$
delimiter ; $$
