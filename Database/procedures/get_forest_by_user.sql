-- --------------------------------------------------------------------------------
-- get_forest_by_user
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_forest_by_user`;
DELIMITER $$

CREATE PROCEDURE `get_forest_by_user`(
    IN userid_in INT
)
BEGIN
IF (SELECT id FROM user WHERE id = userid_in) THEN
    SELECT 'id', 'name', 'description', 'created_at', 'owner_email', 'owner_first_name', 'owner_last_name', 'owner_id'
    UNION
    SELECT f.id, f.name, f.description, f.created_at, u.email, u.first_name, u.last_name, u.id
        FROM forest AS f JOIN user_forest AS uf ON uf.forest_id = f.id AND uf.user_id = userid_in
        LEFT OUTER JOIN user AS u ON u.id = f.owner_id;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
