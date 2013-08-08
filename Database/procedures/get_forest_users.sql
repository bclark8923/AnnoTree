-- --------------------------------------------------------------------------------
-- get_forest_users
-- on success - returns list of users with access to the forest
-- on error - returns 1 if requesting user does not have permissions on that tree
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_forest_users`;
DELIMITER $$

CREATE PROCEDURE `get_forest_users` (
    IN fid_in INT,
    IN req_user INT
)
BEGIN
IF (SELECT id FROM user_forest WHERE user_id = req_user AND forest_id = fid_in) THEN
    SELECT 'id', 'first_name', 'last_name', 'email'
        UNION
        SELECT u.id, u.first_name, u.last_name, u.email 
        FROM user_forest AS uf INNER JOIN user AS u ON uf.user_id = u.id 
        WHERE uf.forest_id = fid_in;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
