-- --------------------------------------------------------------------------------
-- update_task
-- On success - returns a 0 if task was updated, 1 if task stayed the same
-- On error - returns 2 if task does not exist
--          - returns 3 if user does not have access to tree or tree does not exist
--          - returns 4 if task status does not exist
--          - returns 5 if assigned_to user does not exist or have have permissions to tree
--          - returns 6 if leaf does not exist
-- --------------------------------------------------------------------------------
drop procedure if exists `update_task`;
DELIMITER $$

CREATE procedure `update_task`(
    in `taskid` INT,
    in `description` VARCHAR(1024),
    in `status` INT,
    in `leafid` INT,
    in `assignedTo` INT,
    in `due_date` TIMESTAMP,
    in requestingUser INT
)
BEGIN
declare leafcheck int;
declare usercheck int;
declare treecheck int;
select ut.id into treecheck from user_tree ut, task t where ut.user_id = requestingUser and ut.tree_id = t.tree_id and t.id = taskid;
select u.id into usercheck from user u, user_tree ut where u.id = assignedTo and ut.user_id = u.id and ut.tree_id = treecheck;
select id into leafcheck from leaf where id = leafid;
IF (select id from task where id = taskid) THEN
    IF (treecheck) THEN
        IF (select id from task_statuses where id = status) THEN
            IF (assignedTo is null or usercheck) THEN
                IF (leafid is null or leafcheck) THEN
                    update task as t set
                    t.description = description, 
                    t.status = status, 
                    t.leaf_id = leafid,  
                    t.assigned_to = assignedTo, 
                    t.due_date = due_date  
                    where t.id = taskid;
                    IF ROW_COUNT() > 0 THEN
                        select '0';
                    ELSE
                        select '1'; 
                    END IF;
                ELSE
                    select '6';
                END IF;
            ELSE
                select '5';
            END IF;
        ELSE 
            select '4';
        END IF;
    ELSE
        select '3';
    END IF;
ELSE
    select '2';
END IF;
END $$ 
DELIMITER ; $$
