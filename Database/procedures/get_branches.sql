-- --------------------------------------------------------------------------------
-- get_branches
-- Note: Returns a list of branches associated with a user's tree
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_branches`;
DELIMITER $$


CREATE Procedure `get_branches`(
  in user INT,
  in tree INT
)
BEGIN
IF (select id from user_tree where user_id = user and tree_id = tree) THEN
    select 'id', 'name', 'description', 'tree_id', 'created_at' 
    union
    select b.id, b.name, b.description, b.tree_id, b.created_at 
    from branch b, user_branch ub
    where b.id = ub.branch_id
    and b.tree_id = tree;
/*
from branch as b 
    join user_branch ub on
        ub.branch_id = b.id and
        user = ub.user_id and
        b.tree_id = tree;
*/
ELSE
    select '1';
END IF;
END $$ 
DELIMITER ; $$
