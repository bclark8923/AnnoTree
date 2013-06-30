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
IF (select id from user_leaf where user_id = u and leaf_id = leafid) THEN
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
