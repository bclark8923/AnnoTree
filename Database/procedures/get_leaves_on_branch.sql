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
    SELECT l.id, l.name, l.created_at, l.branch_id, l.priority, a.path
        FROM leaf AS l LEFT JOIN (
            SELECT a2.leaf_id, a2.path AS path
                FROM annotation AS a2 JOIN (
                    SELECT MAX(a4.id) AS id
                    FROM annotation a4
                    GROUP BY a4.leaf_id
                ) AS a3 ON a2.id = a3.id
        ) AS a ON l.id = a.leaf_id
        WHERE branch_id = branch_id_in
        ORDER BY priority ASC;
ELSE
    SELECT 'ERROR';
END IF;
END $$ 
DELIMITER ; $$
