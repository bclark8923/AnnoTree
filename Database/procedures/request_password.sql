-- --------------------------------------------------------------------------------
-- reset_password
-- on success returns timestamp
-- on error returns 1 if email is not valid or user is not active
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `request_password`;
DELIMITER $$

CREATE PROCEDURE `request_password` (
    IN email_in VARCHAR(255)
)
BEGIN
IF (SELECT id FROM user WHERE email = email_in AND status = 3) THEN
    SET @result = (SELECT email FROM reset_password WHERE email = email_in);
    IF (@result IS NOT NULL) THEN
        DELETE FROM reset_password WHERE email = email_in;
    END IF;
    INSERT INTO reset_password (email) VALUES (email_in);
    SELECT 'created_at', 'first_name', 'last_name'
    UNION
    SELECT r.created_at, u.first_name, u.last_name 
      FROM reset_password AS r INNER JOIN user AS u 
      ON r.email = u.email 
      WHERE r.email = email_in;
    COMMIT;
ELSE
    select '1';
END IF;
END $$
DELIMITER ; $$
