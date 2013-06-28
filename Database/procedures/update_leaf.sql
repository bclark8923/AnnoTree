-- --------------------------------------------------------------------------------
-- update_leaf
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
use annotree;
drop procedure if exists `update_leaf`;
DELIMITER $$ ;

CREATE procedure `update_leaf` (
   in id INT,
   in name VARCHAR(45),
   in description VARCHAR(1024),
   in owner_user_id INT,
   in branch_id INT
)
BEGIN
update `annotree`.`leaf` as leaf set
  leaf.name = name , leaf.description = description, leaf.owner_user_id = owner_user_id, leaf.branch_id = branch_id
  where leaf.id = id; 
select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at'
union
select * from leaf where leaf.id = id;
END
