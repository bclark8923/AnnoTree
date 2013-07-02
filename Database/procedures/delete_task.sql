-- --------------------------------------------------------------------------------
-- delete_task
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_task`;
DELIMITER $$


CREATE Procedure `delete_task`(
  in id int,
  in user_id int
  )
BEGIN
IF (select id from user_tree where user_tree.user_id = user_id) THEN
        delete from task where task.id = id;
        if row_count() = 1 then
          select '0';
        ELSE 
          select '2';
        END IF;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
