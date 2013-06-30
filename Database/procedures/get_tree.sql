-- --------------------------------------------------------------------------------
-- get_tree
-- Note: Returns the information associated with a single tree
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_tree`;
DELIMITER $$

CREATE PROCEDURE `get_tree`(
    in u INT,
    in t INT
)
BEGIN
IF (select id from user_tree where user_id = u and tree_id = t) THEN
    select 'id', 'name', 'forest_id', 'description', 'logo', 'token', 'created_at'
    union
    select id, name, forest_id, description, logo, token, created_at
    from tree
    where id = t;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
