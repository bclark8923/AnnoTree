-- --------------------------------------------------------------------------------
-- add_user_to_tree
-- On success - returns 0
-- On failure - returns 1 (requsting user doesn't have permissions on that tree)
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `add_user_to_tree`;
DELIMITER $$


CREATE Procedure `add_user_to_tree`(
    in treeid int,
    in user_to_add int,
    in requesting_user INT
)
BEGIN
IF (select id from user_tree where tree_id = treeid and user_id = requesting_user) THEN
    IF (select id from user where id = user_to_add) THEN
        START TRANSACTION;
        insert into user_tree (user_id, tree_id) values (user_to_add, treeid);
        insert into user_forest(user_id, forest_id) 
          select user_to_add, tree.forest_id from tree where tree.id = treeid;
        Commit;
        select '0';
    ELSE
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
