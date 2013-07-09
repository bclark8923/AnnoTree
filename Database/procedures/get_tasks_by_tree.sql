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
    select 'id', 'description', 'status', 'leaf_id', 'leaf_name', 'tree_id', 'assigned_to', 'assigned_to_first_name', 'assigned_to_last_name', 'due_date', 'created_at', 'created_by', 'created_by_first_name', 'created_by_last_name'
    union 
    select ta.id, ta.description, ta.status, ta.leaf_id, leaf.name, ta.tree_id, ta.assigned_to, assigned.first_name, assigned.last_name, ta.due_date, ta.created_at, ta.created_by, created.first_name, created.last_name
    from task ta, 
    (select t.id, u.first_name, u.last_name from task t left outer join user u on u.id = t.assigned_to) as assigned,
    (select t.id, u.first_name, u.last_name from task t left outer join user u on u.id = t.created_by) as created,
    (select t.id, l.name from task t left outer join leaf l on l.id = t.leaf_id) as leaf
    where ta.tree_id = treeid
    and assigned.id = ta.id
    and created.id = ta.id
    and leaf.id = ta.id;
ELSE 
    select '1';
END IF;
END $$
delimiter ; $$
