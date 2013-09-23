-- --------------------------------------------------------------------------------
-- create_branch
-- returns  0 - success: returns branch info
--          1 - error: user does not have permissions on tree
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_branch`;
DELIMITER $$

CREATE PROCEDURE `create_branch` (
    IN user_id_in INT,
    IN tree_id_in INT,
    IN name_in VARCHAR(45)
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
    INSERT INTO `annotree`.`branch` (tree_id, name) VALUES (tree_id_in, name_in);
    SET @branch_id = LAST_INSERT_ID();
    SELECT 'id', 'name', 'tree_id', 'description', 'created_at'
        UNION
        SELECT id, name, tree_id, description, created_at
        FROM branch
        WHERE id = @branch_id;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
