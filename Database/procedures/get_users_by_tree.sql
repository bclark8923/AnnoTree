-- --------------------------------------------------------------------------------
-- get_users_by_tree
-- On success: Returns the users that have access to a tree
-- On failure: Returns 1 if the user does not have access to that tree
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
    SELECT 'id', 'first_name', 'last_name', 'email', 'status'
    UNION
    SELECT u.id, u.first_name, u.last_name, u.email, u.status
    from user u, user_tree ut 
    where ut.user_id = u.id 
    and ut.tree_id = treeid;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
