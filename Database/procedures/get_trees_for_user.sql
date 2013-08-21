-- --------------------------------------------------------------------------------
-- get_trees_for_user
-- returns 0 - success
-- TODO: See if this is being used if so rename it
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_trees_for_user`;
DELIMITER $$

CREATE PROCEDURE `get_trees_for_user`(
    IN uid_in INT
)
BEGIN
SELECT 'name', 'token'
    UNION
    SELECT t.name, t.token
    FROM tree AS t
    JOIN user_tree AS ut ON ut.tree_id = t.id 
    WHERE ut.user_id = uid_in;
END $$ 
DELIMITER ; $$
