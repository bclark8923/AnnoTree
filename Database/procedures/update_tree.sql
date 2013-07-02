-- --------------------------------------------------------------------------------
-- update_tree
-- YEAH BUDDY
-- --------------------------------------------------------------------------------
drop procedure if exists `update_tree`;
DELIMITER $$

CREATE procedure `update_tree`(
  in `id` INT,
  `name` VARCHAR(45),
  `forest_id` INT,
  `description` VARCHAR(1024),
  `logo` VARCHAR(1024),
  `token` VARCHAR(64),
  `owner_id` INT
  )
BEGIN
update tree as t set
  t.name = name, 
  t.description = description,
  t.logo = logo,
  t.token = token,
  t.owner_id = owner_id
where t.id = id;
if ROW_COUNT() > 0 then 
select 'id', 'name', 'forest_id', 'description', 'logo', 'token', 'owner_id', 'created_date'
union
select * from tree where tree.id = id;
else
select '1'; 
end if;
END
