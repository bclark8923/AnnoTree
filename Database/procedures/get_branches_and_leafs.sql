-- --------------------------------------------------------------------------------
-- get_branches
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_branches_and_leafs`;
DELIMITER $$


CREATE Procedure `get_branches_and_leafs`(
  in user INT,
  in tree INT
  )
BEGIN
select 'branch id', 'branch name', 'branch description', 'branch tree_id', 'branch created_at', 'leaf name', 'leaf comment', 'leaf owner', 'leaf created_at' union
select b.id, b.name, b.description, b.tree_id, b.created_at, l.name, l.`comment`, l.owner_user_id, l.created_at
from branch as b 
    join user_branch ub on
        ub.branch_id = b.id and
        user = ub.user_id and
        b.tree_id = tree
    join leaf as l on
        l.branch_id = b.id
    join user_leaf as ul on
        ul.user_id = user;
END $$ 
DELIMITER ; $$
