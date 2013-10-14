-- --------------------------------------------------------------------------------
-- reset_password
-- returns  0 - success
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `update_password`;
DELIMITER $$

CREATE PROCEDURE `update_password` (
    IN pass_in VARCHAR(128),
    IN user_id_in INT
)
BEGIN
UPDATE user SET password = pass_in WHERE id = user_id_in;
SELECT '0';
END $$
DELIMITER ; $$
