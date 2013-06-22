-- --------------------------------------------------------------------------------
-- get_leafs
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_leafs`;
DELIMITER $$


CREATE Procedure `get_leafs`(
  in user INT,
  in branch INT
  )
BEGIN
select 'id', 'name', 'comment', 'owner_user_id', 'assignee_user_id', 'branch_id', 'created_at' union
select l.id, l.name, l.comment, l.owner_user_id, l.assignee_user_id, l.branch_id, l.created_at 
from leaf as l 
    join user_leaf ul on
        ul.leaf_id = l.id and
        user = ul.user_id and
        l.branch_id = branch;
END $$ 
DELIMITER ; $$
