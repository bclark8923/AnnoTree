-- --------------------------------------------------------------------------------
-- login_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION `login_user`(
  u VARCHAR(45),
  p VARCHAR(45))
returns VARCHAR(1024)
BEGIN
DECLARE user_data varchar(255) default '0';
SET user_data = concat((select concat(username, ' ', 
                                      password, ' ', 
                                      first_name, ' ',
                                      last_name, ' ',
                                      email, ' ',
                                      lang, ' ',
                                      time_zone, ' ',
                                      profile_image_path, ' ')
            from user 
            where username = u and password = p), '');
return @user_data;
END
