-- --------------------------------------------------------------------------------
-- delete_user_from_tree
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_user_from_tree`;
DELIMITER $$


CREATE Procedure `delete_user_from_tree`(
    in treeid int,
    in del_user int,
    in req_user int
)
BEGIN
IF (select ut.id from user_tree ut where ut.user_id = req_user and ut.tree_id = treeid) THEN
        delete from user_tree where user_id = del_user and tree_id = treeid;
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
