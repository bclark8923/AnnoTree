-- --------------------------------------------------------------------------------
-- update_login
-- updates the time the user logged into the CCP
-- TODO: Can we use this in another prodecure
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `update_login`;
DELIMITER $$

CREATE PROCEDURE `update_login` (
    IN userid_in VARCHAR(255))
BEGIN
UPDATE user
    SET last_login = NOW()
    WHERE id = userid_in;
END $$
DELIMITER ; $$
