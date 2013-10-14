-- --------------------------------------------------------------------------------
-- update_user
-- returns  sucess: information for an individual user
--          1 - error: email already exists in system
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `update_user`;
DELIMITER $$

CREATE PROCEDURE `update_user`(
    IN user_id_in INT,
    IN email_in VARCHAR(255),
    IN fname VARCHAR(45),
    IN lname VARCHAR(45),
    IN profile_img VARCHAR(256)

)
BEGIN
SET @email_count = (SELECT count(*) FROM user WHERE email = email_in AND id != user_id_in);
IF (@email_count != 0) THEN
    SELECT '1';
ELSE
    UPDATE user SET
        email = email_in,
        first_name = fname,
        last_name = lname,
        profile_image_path = profile_img
        WHERE id = user_id_in;
    SELECT 'id', 'first_name', 'last_name', 'email', 'lang', 'time_zone', 'profile_image_path', 'created_at', 'status'
    UNION
    SELECT id, first_name,  last_name, email, lang, time_zone, profile_image_path, created_at, status
        FROM user 
        WHERE id = user_id_in;
END IF;
END $$
DELIMITER ; $$
