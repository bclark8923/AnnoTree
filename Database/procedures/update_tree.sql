-- --------------------------------------------------------------------------------
-- update_tree
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
use annotree;
drop procedure if exists `update_tree`;
DELIMITER $$ 

CREATE procedure `update_tree` (
  `id` INT,
  `name` VARCHAR(45),
  `forest_id` INT,
  `description` VARCHAR(1024),
  `logo` VARCHAR(1024)
)
BEGIN
update `annotree`.`tree` as tree set
  tree.name = name , tree.forest_id = forest_id, tree.description = description, tree.logo = logo
  where tree.id = id;
if (select ROW_COUNT() > 0) then 
select 'id', 'name', 'forest_id', 'description', 'logo', 'created_at'
union
select * from tree where tree.id = id;
END IF;
END
