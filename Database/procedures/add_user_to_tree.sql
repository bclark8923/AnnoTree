-- --------------------------------------------------------------------------------
-- add_user_to_tree
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `add_user_to_tree`;
DELIMITER $$


CREATE Procedure `add_user_to_tree`(
  in tree_id int,
  in user_id int
  )
BEGIN
START TRANSACTION;
insert into user_tree (user_id, tree_id) values (user_id, tree_id);
insert into user_forest(user_id, forest_id) 
  select user_id, tree.forest_id from tree where tree.id = tree_id;
insert into user_branch(user_id, branch_id) 
  select user_id, branch.id from branch where branch.tree_id = tree_id;
insert into user_leaf(user_id, leaf_id)
  select user_id, leaf.id from leaf 
    inner join branch as b
      on b.tree_id = tree_id and
      leaf.branch_id = b.id
    where leaf.branch_id = b.id;
Commit;
END $$
delimiter ; $$
