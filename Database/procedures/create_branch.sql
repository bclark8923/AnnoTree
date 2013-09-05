-- --------------------------------------------------------------------------------
-- create_branch
-- returns  0 - success
--          1 - error: user does not have permissions
--          2 - error: tree does not exist
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_branch`;
DELIMITER $$

CREATE PROCEDURE `create_branch` (
    IN user_id_in INT,
    IN tree_id_in INT,
    IN name_in VARCHAR(45),
    IN desc_in VARCHAR(1024)
)
BEGIN
IF (SELECT id FROM user WHERE id = user_id_in) THEN
    IF (SELECT id FROM tree WHERE id = tree_id_in) THEN
        INSERT INTO `annotree`.`branch`
          (tree_id, name, description)
          VALUES (tree_id_in, name_in, desc_in);
        SELECT '0';
    ELSE
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
