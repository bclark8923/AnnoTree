-- --------------------------------------------------------------------------------
-- get_users_by_tree
-- On success: Returns the users that have access to a tree
-- On failure: Returns 1 if the user does not have access to that tree
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_users_by_tree`;
DELIMITER $$

CREATE procedure `get_users_by_tree`(
    userid INT,
    treeid INT
)
BEGIN
IF (select id from user_tree where user_id = userid and tree_id = treeid) THEN
    select 'id', 'first_name', 'last_name', 'email', 'status'
    union
    select u.id, u.first_name, u.last_name, u.email, u.status
    from user u, user_tree ut 
    where ut.user_id = u.id 
    and ut.tree_id = treeid;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
