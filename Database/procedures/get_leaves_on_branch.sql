-- --------------------------------------------------------------------------------
-- get_leaves_on_branch
-- returns  success - Returns a list of leaves associated with a branch
--          ERROR - error: user does not have permissions
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_leaves_on_branch`;
DELIMITER $$

CREATE PROCEDURE `get_leaves_on_branch`(
    IN user_id_in INT,
    IN tree_id_in INT,
    IN branch_id_in INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
    SELECT id, name, created_at, branch_id, priority
        FROM leaf
        WHERE branch_id = branch_id_in
        ORDER BY priority ASC;
ELSE
    SELECT 'ERROR';
END IF;
END $$ 
DELIMITER ; $$
