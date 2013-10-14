-- --------------------------------------------------------------------------------
-- get_user
-- returns the information for an individual user
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_user`;
DELIMITER $$

CREATE PROCEDURE `get_user`(
    IN e VARCHAR(255)
)
BEGIN
SELECT 'id', 'first_name',  'last_name', 'email', 'lang', 'time_zone', 'profile_image_path', 'created_at', 'status', 'notf_tree_invite', 'notf_leaf_assign' 
UNION
SELECT id, first_name,  last_name, email, lang, time_zone, profile_image_path, created_at, status, notf_tree_invite, notf_leaf_assign
    FROM user 
    WHERE email = e;
END $$
DELIMITER ; $$
