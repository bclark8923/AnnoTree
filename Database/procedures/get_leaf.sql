-- --------------------------------------------------------------------------------
-- get_leaf
-- Note: Returns a the information associated with an individual leaf
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_leaf`;
DELIMITER $$


CREATE Procedure `get_leaf`(
  in u INT,
  in leafid INT
  )
BEGIN
IF (select ut.id from user_tree as ut, branch b, leaf l
        where ut.user_id = u 
        and leafid = l.id
        and b.id = l.branch_id
        and b.tree_id = ut.tree_id) 
        THEN
    select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at' 
    union
    select l.id, l.name, l.description, l.owner_user_id, l.branch_id, l.created_at 
    from leaf as l
    where l.id = leafid;
ELSE
    select '1';
END IF;
END $$ 
DELIMITER ; $$
