-- --------------------------------------------------------------------------------
-- get_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_trees_by_user_by_forest`;
DELIMITER $$


CREATE Procedure `get_trees_by_user_by_forest`(
  in u INT,
  in f INT
  )
BEGIN
select 'id', 'name', 'forest_id', 'description', 'created_at', 'token', 'logo' 
union
select tree.id, tree.name, tree.forest_id, tree.description, tree.created_at, tree.token, tree.logo 
from tree 
    join user_tree ut on
        ut.tree_id = tree.id and
        u = ut.user_id and
        tree.forest_id = f;
END $$ 
DELIMITER ; $$
