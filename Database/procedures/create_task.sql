-- --------------------------------------------------------------------------------
-- create_task
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_task`;
DELIMITER $$


CREATE Procedure `create_task`(
  in d VARCHAR(1024),
  in status INT,
  in `leaf_id` INT,
  in `tree_id` INT,
  in `assigned_to` INT,
  in `due_date` TIMESTAMP,
  in `created_by` INT)
BEGIN
IF (select id from user where id = created_by) THEN
    IF (select id from tree where id = tree_id) THEN
        insert into `annotree`.`task` 
          (description, status, leaf_id, tree_id, assigned_to, due_date, created_by)
          values 
          (d, status, leaf_id, tree_id, assigned_to, due_date, created_by);
        set @id = LAST_INSERT_ID();
        select 'id', 'name', 'description', 'status', 'leaf_id', 'tree_id', 'assigned_to', 'due_date', 'created_at', 'created_by'
        union 
        select id, name, description, status, leaf_id, tree_id, assigned_to, due_date, created_at, created_by
        from task
        where id = @id;
    ELSE 
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
