-- --------------------------------------------------------------------------------
-- delete_leaf
-- returns 0 - success
-- returns 1 - failure
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_leaf`;
DELIMITER $$


CREATE Procedure `delete_leaf`(
  in user INT,
  in leaf_id INT
  )
BEGIN
IF (select id from user where id = user) then
SET FOREIGN_KEY_CHECKS=0;
delete l, a  
        from leaf as l 
        inner join annotation as a on
            l.id = a.leaf_id
    where
        l.id = leaf_id;
if row_count() > 0 then select '0';
else select '1';
end if;
SET FOREIGN_KEY_CHECKS=1;
END IF;
END $$
delimiter ; $$
