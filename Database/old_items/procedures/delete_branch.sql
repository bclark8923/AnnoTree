-- --------------------------------------------------------------------------------
-- delete_branch
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_branch`;
DELIMITER $$


CREATE Procedure `delete_branch`(
  in user INT,
  in branch_id INT
  )
BEGIN
IF (select id from user where id = user) then
SET FOREIGN_KEY_CHECKS=0;
delete b, ub 
        from branch as b 
        inner join user_branch as ub on
            ub.branch_id = b.id
    where
        b.id = branch_id and
        ub.user_id = user;
SET FOREIGN_KEY_CHECKS=1;
END IF;
END $$
delimiter ; $$
