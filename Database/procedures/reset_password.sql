-- --------------------------------------------------------------------------------
-- reset_password
-- on success returns timestamp
-- on error returns 1 if no entry exists in reset_password table
--          returns 2 if time has expired to reset the password
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `reset_password`;
DELIMITER $$

CREATE PROCEDURE `reset_password` (
    IN email_in VARCHAR(255),
    IN pass_in VARCHAR(128),
    IN token_in VARCHAR(64)
)
BEGIN
SET @email = (SELECT email FROM reset_password WHERE email = email_in AND hash = token_in);
IF (@email IS NOT NULL) THEN
    SET @hour = (SELECT HOUR(TIMEDIFF(NOW(), created_at)) 
      FROM reset_password WHERE email = email_in);
    IF (@hour = 0) THEN
        DELETE FROM reset_password WHERE email = email_in;
        UPDATE user SET password = pass_in WHERE email = email_in;
        COMMIT;
        SELECT '0';
    ELSE
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
