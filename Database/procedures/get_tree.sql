-- --------------------------------------------------------------------------------
-- get_tree
-- Note: Returns the information associated with a single tree
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_tree`;
DELIMITER $$

CREATE PROCEDURE `get_tree`(
    IN user_id_in INT,
    IN tree_id_in INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
    SELECT 'id', 'name', 'forest_id', 'description', 'logo', 'token', 'created_at', 'forest_owner_email', 'forest_owner_first_name', 'forest_owner_last_name', 'forest_owner_id'
        UNION
        SELECT t.id, t.name, t.forest_id, t.description, t.logo, t.token, t.created_at, u.email, u.first_name, u.last_name, u.id
        FROM tree AS t JOIN forest AS f ON t.forest_id = f.id 
            LEFT OUTER JOIN user AS u ON u.id = f.owner_id
        WHERE t.id = tree_id_in and t.active = 1;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
