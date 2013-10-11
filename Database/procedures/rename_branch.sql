-- --------------------------------------------------------------------------------
-- rename_branch
-- returns  0 - success
--          1 - error: user does not have permissions on that tree
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `rename_branch`;
DELIMITER $$

CREATE PROCEDURE `rename_branch`(
    IN req_user INT,
    IN tree_id_in INT,
    IN branch_id_in INT,
    IN branch_name VARCHAR(45)
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = req_user AND tree_id = tree_id_in) THEN
        UPDATE branch SET name = branch_name 
            WHERE id = branch_id_in;
        SELECT '0'; 
ELSE 
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
