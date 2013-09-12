-- --------------------------------------------------------------------------------
-- get_sub_branches
-- returns  success - Returns a list of sub branches associated with a user's branch
--          1 - error: user does not have permissions
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_sub_branches`;
DELIMITER $$

CREATE PROCEDURE `get_sub_branches`(
    IN user_id_in INT,
    IN parent_branch INT
)
BEGIN
IF (SELECT ut.id FROM user_tree AS ut JOIN branch AS b ON b.tree_id = ut.tree_id
    WHERE user_id = user_id_in AND b.id = parent_branch) THEN
    SELECT 'id', 'name', 'description', 'tree_id', 'created_at'
    UNION
    SELECT b.id, b.name, b.description, b.tree_id, b.created_at
        FROM branch AS b LEFT OUTER JOIN branch_link AS p ON b.id = p.destination_branch_id
        WHERE p.source_branch_id = parent_branch;
ELSE
    SELECT '1';
END IF;
END $$ 
DELIMITER ; $$
