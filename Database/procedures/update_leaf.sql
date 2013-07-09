-- --------------------------------------------------------------------------------
-- update_leaf
-- On success - returns a 0 if leaf was updated, 1 if leaf stayed the same
-- On error - returns a 2 if leaf does not exist
--          - returns a 3 if user does not have permission to that tree
--          - returns a 4 if branch they are trying to move leaf to is not in the same tree or does not exist
-- --------------------------------------------------------------------------------
use annotree;
drop procedure if exists `update_leaf`;
DELIMITER $$

CREATE procedure `update_leaf` (
   in leafid INT,
   in name VARCHAR(45),
   in description VARCHAR(1024),
   in req_user INT,
   in branchid INT
)
BEGIN
declare treeid int;
select t.id into treeid from user_tree ut, tree t, branch b, leaf l where l.id = leafid and b.id = l.branch_id and b.tree_id = t.id and t.id = ut.tree_id and ut.user_id = req_user;
IF (select id from leaf where id = leafid) THEN
    IF (treeid) THEN
        IF (select id from branch b where b.id = branchid and b.tree_id = treeid) THEN
            update `annotree`.`leaf` as leaf set
            leaf.name = name,
            leaf.description = description,
            leaf.owner_user_id = owner_user_id,
            leaf.branch_id = branchid
            where leaf.id = leafid;
            IF row_count() > 0 THEN 
                select '0';
            ELSE
                select '1';
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
