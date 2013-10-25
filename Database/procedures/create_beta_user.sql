-- --------------------------------------------------------------------------------
-- create_beta_user
-- returns 0 - success
-- otherwise returns error:
-- 1 - existing beta user, allowed to sign up
-- 2 - invited user, can sign up
-- 3 - already an active User
-- 4 - already signed up for the beta
-- 5 - invalid email
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `create_beta_user`;
DELIMITER $$

CREATE PROCEDURE `create_beta_user`(
    IN email_in VARCHAR(255),
    IN new_user_img VARCHAR(256)
)
BEGIN
SET @status = (SELECT status FROM user WHERE email = email_in);
If (@status = 3) THEN
    select '3';
ELSEIF (@status = 2) THEN
    select '2';
ELSEIF (@status = 1) THEN
    select '1';
ELSEIF (@status = 0) THEN
    select '4';
ELSE
    IF email_in REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' THEN
        INSERT INTO user (email, status, profile_image_path) VALUES (email_in, 0, new_user_img);
        SELECT '0';
    ELSE 
        SELECT '5';
    END IF;
END IF;
END $$
DELIMITER ; $$
