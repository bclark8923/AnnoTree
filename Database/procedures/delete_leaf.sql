-- --------------------------------------------------------------------------------
-- delete_leaf
-- returns 0 - success
-- returns 1 - failure
-- returns 2 - user does not have permission to delete that leaf
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_leaf`;
DELIMITER $$

CREATE Procedure `delete_leaf`(
    in userid INT,
    in leafid INT
)
BEGIN
--TODO: joins
IF (select ut.id from user_tree ut, branch b, leaf l where l.id = leafid and l.branch_id = b.id and b.tree_id = ut.tree_id and ut.user_id = userid) then
    SET FOREIGN_KEY_CHECKS=0;
    delete l, a  
            from leaf as l 
            left outer join annotation as a on
                l.id = a.leaf_id
        where
            l.id = leafid;
    if row_count() > 0 then 
        select '0';
        SET FOREIGN_KEY_CHECKS=1;
    else 
        select '1';
    end if;
ELSE
    select '2';
END IF;
END $$
delimiter ; $$
