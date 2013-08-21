-- --------------------------------------------------------------------------------
-- get_leafs
-- Note: Returns a list of leaves
-- TODO: see if this is getting used
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_leafs`;
DELIMITER $$


CREATE Procedure `get_leafs`(
  in b INT
  )
BEGIN
select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at' 
union
select l.id, l.name, l.description, l.owner_user_id, l.branch_id, l.created_at 
from leaf as l
where l.branch_id = b;
END $$ 
DELIMITER ; $$
