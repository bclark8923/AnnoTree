-- --------------------------------------------------------------------------------
-- rename_tree
-- returns  0 - success
--          1 - error: user does not have permissions
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `rename_tree`;
DELIMITER $$

CREATE PROCEDURE `rename_tree`(
    IN tree_id_in INT,
    IN tree_name VARCHAR(45),
    IN req_user INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = req_user AND tree_id = tree_id_in) THEN
        UPDATE tree SET name = tree_name 
            WHERE id = tree_id_in;
        SELECT '0'; 
ELSE 
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
