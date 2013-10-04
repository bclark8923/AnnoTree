-- --------------------------------------------------------------------------------
-- get_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_trees_by_user_by_forest`;
DELIMITER $$

CREATE PROCEDURE `get_trees_by_user_by_forest`(
    IN user_id_in INT,
    IN forest_id_in INT
)
BEGIN
SELECT 'id', 'name', 'forest_id', 'description', 'created_at', 'token', 'logo', 'default_branch'
UNION
SELECT t.id, t.name, t.forest_id, t.description, t.created_at, t.token, t.logo, b.id
    FROM tree AS t 
    JOIN user_tree AS ut ON ut.tree_id = t.id
    JOIN branch AS b ON b.tree_id = t.id
    WHERE ut.user_id = user_id_in
    AND t.forest_id = forest_id_in
    and t.active = 1
    AND b.name = 'User Feedback';
END $$ 
DELIMITER ; $$
