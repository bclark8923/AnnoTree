-- --------------------------------------------------------------------------------
-- get_user_info
-- returns the information for an individual user
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_user_info`;
DELIMITER $$

CREATE PROCEDURE `get_user_info` (
    IN id_in INT
)
BEGIN
SELECT 'id', 'first_name',  'last_name', 'email', 'lang', 'time_zone', 'profile_image_path', 'created_at', 'status', 'notf_tree_invite', 'notf_leaf_assign'
UNION
SELECT id, first_name,  last_name, email, lang, time_zone, profile_image_path, created_at, status, notf_tree_invite, notf_leaf_assign
    FROM user 
    WHERE id = id_in;
END $$
DELIMITER ; $$
