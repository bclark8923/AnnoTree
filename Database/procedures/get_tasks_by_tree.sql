-- --------------------------------------------------------------------------------
-- get_tasks_by_tree
-- returns 1 tree does not exist or user does not have permissions to that tree
-- returns all tasks under a tree if all goes well
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_tasks_by_tree`;
DELIMITER $$


CREATE Procedure `get_tasks_by_tree`(
    in `userid` INT,
    in `treeid` INT
)
BEGIN
IF (select t.id from tree t, user_tree ut where t.id = treeid and ut.tree_id = treeid and ut.user_id = userid) THEN
    select 'id', 'description', 'status', 'leaf_id', 'tree_id', 'assigned_to', 'due_date', 'created_at', 'created_by'
    union 
    select id, description, status, leaf_id, tree_id, assigned_to, due_date, created_at, created_by
    from task
    where tree_id = treeid;
ELSE 
    select '1';
END IF;
END $$
delimiter ; $$
