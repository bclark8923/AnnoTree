-- --------------------------------------------------------------------------------
-- delete_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_tree`;
DELIMITER $$


CREATE Procedure `delete_tree`(
  in user INT,
  in tree_id INT
  )
BEGIN
IF (select id from user where id = user) then
SET FOREIGN_KEY_CHECKS=0;
delete t, tu 
        from tree as t 
        inner join user_tree as tu on
            tu.tree_id = t.id
    where
        t.id = tree_id and
        tu.user_id = user;
SET FOREIGN_KEY_CHECKS=1;
END IF;
END $$
delimiter ; $$
