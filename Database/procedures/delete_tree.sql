-- --------------------------------------------------------------------------------
-- delete_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_tree`;
DELIMITER $$


CREATE Procedure `delete_tree`(
  in req_user INT,
  in treeid INT
  )
BEGIN
IF (select id from user_tree where user_id = req_user and tree_id = treeid) then
  SET FOREIGN_KEY_CHECKS=0;
    SET @forestid = (SELECT forest_id FROM tree WHERE id = treeid);
  update tree as t
    join user_tree as ut
        on ut.tree_id = t.id
    set t.active = 0
      where
          t.id = treeid and
          ut.user_id = req_user;
  SET FOREIGN_KEY_CHECKS=1;
    select '0'
        UNION
        SELECT @forestid;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
