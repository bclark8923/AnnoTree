-- --------------------------------------------------------------------------------
-- delete_task
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_task`;
DELIMITER $$


CREATE Procedure `delete_task`(
  in taskid int,
  in req_user int
  )
BEGIN
--TODO:JOINS
IF (select ut.id from user_tree ut, task t where ut.user_id = req_user and ut.tree_id = t.tree_id and t.id = taskid) THEN
        delete from task where task.id = taskid;
        if row_count() = 1 then
          select '0';
        ELSE 
          select '1';
        END IF;
ELSE
    select '2';
END IF;
END $$
delimiter ; $$
