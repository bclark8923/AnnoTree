-- --------------------------------------------------------------------------------
-- get_leaf
-- Note: Returns a the information associated with an individual leaf
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_leaf`;
DELIMITER $$


CREATE Procedure `get_leaf`(
  in u INT,
  in leaf_id INT
  )
BEGIN
IF (select ut.user_id from user_tree as ut
        inner join branch as b on
            b.tree_id = ut.id
        inner join leaf as l on
            l.branch_id = b.id 
        where ut.user_id = u and leaf_id = l.id) THEN
    select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at' 
    union
    select l.id, l.name, l.description, l.owner_user_id, l.branch_id, l.created_at 
    from leaf as l
    where l.id = leaf_id;
ELSE
    select '1';
END IF;
END $$ 
DELIMITER ; $$
