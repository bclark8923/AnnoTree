-- --------------------------------------------------------------------------------
-- get_branches
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_branches`;
DELIMITER $$


CREATE Procedure `get_branches`(
  in user INT,
  in tree INT
  )
BEGIN
select 'id', 'name', 'description', 'tree_id', 'created_at' union
select b.id, b.name, b.description, b.tree_id, b.created_at 
from branch as b 
    join user_branch ub on
        ub.branch_id = b.id and
        user = ub.user_id and
        b.tree_id = tree;
END $$ 
DELIMITER ; $$
