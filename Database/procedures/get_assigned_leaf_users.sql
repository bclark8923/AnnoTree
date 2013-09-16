-- --------------------------------------------------------------------------------
-- get_assigned_leaf_users
-- returns  0 - success
--          1 - error: requesting user does not have permission to assign to that leaf
--          2 - error: assigned user does not have permission on that leaf
--          3 - error: assignment already exists
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_assigned_leaf_users`;
DELIMITER $$

CREATE PROCEDURE `get_assigned_leaf_users`(
    IN leaf_id_in INT
)
BEGIN
SELECT 'id', 'first_name', 'last_name', 'status', 'email', 'profile_image_path'
    UNION
    SELECT u.id, u.first_name, u.last_name, u.status, u.email, u.profile_image_path
    FROM user AS u JOIN leaf_assignments AS l ON u.id = l.user_id
    WHERE l.leaf_id = leaf_id_in;
END $$
DELIMITER ; $$
