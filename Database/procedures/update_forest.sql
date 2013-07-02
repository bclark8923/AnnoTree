-- --------------------------------------------------------------------------------
-- update_forest
-- YEAH BUDDY
-- --------------------------------------------------------------------------------
drop procedure if exists `update_forest`;
DELIMITER $$

CREATE procedure `update_forest`(
  in `id` INT,
  in `name` VARCHAR(45),
  in `description` VARCHAR(1024)
  )
BEGIN
update forest as f set
  f.name = name, 
  f.description = description
where f.id = id;
if ROW_COUNT() > 0 then 
select 'id', 'name', 'description'
union
select * from forest where forest.id = id;
else
select '1'; 
end if;
END
