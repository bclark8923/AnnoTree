-- --------------------------------------------------------------------------------
-- get_branches
-- Note: Returns a list of branches and leaves associated with a tree
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_branches_and_leafs`;
DELIMITER $$


CREATE Procedure `get_branches_and_leafs`(
  in user INT,
  in tree INT
  )
BEGIN
select 'branch id', 'branch name', 'branch description', 'branch tree_id', 'branch created_at', 'leaf name', 'leaf description', 'leaf owner', 'leaf created_at' union
select b.id, b.name, b.description, b.tree_id, b.created_at, l.name, l.description, l.owner_user_id, l.created_at
from branch as b
join leaf l on
b.tree_id = tree
and l.branch_id = b.id;
END $$ 
DELIMITER ; $$
