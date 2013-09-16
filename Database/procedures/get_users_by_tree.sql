-- --------------------------------------------------------------------------------
-- get_users_by_tree
-- returns  success: the users that have access to a tree
--          1 - error: the user does not have access to that tree
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_users_by_tree`;
DELIMITER $$

CREATE PROCEDURE `get_users_by_tree`(
    IN userid INT,
    IN treeid INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = userid AND tree_id = treeid) THEN
    SELECT 'id', 'first_name', 'last_name', 'email', 'status', 'profile_image_path'
        UNION
        SELECT u.id, u.first_name, u.last_name, u.email, u.status, u.profile_image_path
        FROM user u, user_tree ut 
        WHERE ut.user_id = u.id 
        AND ut.tree_id = treeid;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
