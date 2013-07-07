-- --------------------------------------------------------------------------------
-- update_task
-- YEAH BUDDY
-- --------------------------------------------------------------------------------
drop procedure if exists `update_task`;
DELIMITER $$

CREATE procedure `update_task`(
  in `id` INT,
  in `description` VARCHAR(1024),
  in `status` INT,
  in `leaf_id` INT,
  in `tree_id` INT,
  in `assigned_to` INT,
  in `due_date` TIMESTAMP
  )
BEGIN
update task as t set
  t.description = description, 
  t.status = status, 
  t.leaf_id = leaf_id, 
  t.tree_id = tree_id, 
  t.assigned_to = assigned_to, 
  t.due_date = due_date  
where t.id = id;
if ROW_COUNT() > 0 then 
select '0';
else
select '1'; 
end if;
END
