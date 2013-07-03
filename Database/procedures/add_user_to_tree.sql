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
    in userToAdd int,
    in requestingUser INT
)
BEGIN
IF (select id from user_tree where tree_id = treeid and user_id = requestingUser) THEN
    IF (select id from user where id = userToAdd) THEN
        START TRANSACTION;
        insert into user_tree (user_id, tree_id) values (userToAdd, treeid);
        insert into user_forest(user_id, forest_id) 
          select userToAdd, tree.forest_id from tree where tree.id = treeid;
        insert into user_branch(user_id, branch_id) 
          select userToAdd, branch.id from branch where branch.tree_id = treeid;
        insert into user_leaf(user_id, leaf_id)
          select userToAdd, leaf.id from leaf 
            inner join branch as b
              on b.tree_id = treeid and
              leaf.branch_id = b.id
            where leaf.branch_id = b.id;
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
