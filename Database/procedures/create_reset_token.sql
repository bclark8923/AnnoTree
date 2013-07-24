-- --------------------------------------------------------------------------------
-- create_reset_token
-- returns nothing
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_reset_token`;
DELIMITER $$

CREATE PROCEDURE `create_reset_token` (
    IN email_in VARCHAR(255),
    IN token VARCHAR(64)
)
BEGIN
    UPDATE reset_password SET hash = token WHERE email = email_in;
    COMMIT;
END $$
DELIMITER ; $$
