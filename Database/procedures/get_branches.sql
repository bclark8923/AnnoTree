-- --------------------------------------------------------------------------------
-- get_branches
-- returns  success - Returns a list of branches associated with a user's tree
--          1 - error: user does not have permissions
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_branches`;
DELIMITER $$

CREATE PROCEDURE `get_branches`(
    IN user INT,
    IN tree INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user AND tree_id = tree) THEN
    SELECT 'id', 'name', 'description', 'tree_id', 'created_at', 'parent_branch', 'priority'
    UNION
    SELECT b.id, b.name, b.description, b.tree_id, b.created_at, p.source_branch_id, p.priority
        FROM branch AS b inner join user_tree AS ut 
            ON ut.tree_id = b.tree_id AND user = ut.user_id
            LEFT OUTER JOIN branch_link AS p ON b.id = p.destination_branch_id
        WHERE b.tree_id = tree;
ELSE
    SELECT '1';
END IF;
END $$ 
DELIMITER ; $$
