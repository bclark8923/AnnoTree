-- --------------------------------------------------------------------------------
-- create_leaf_on_tree
-- creates a leaf on a tree with a single branch (used for iOS uploads)
-- returns 1 if tree does not exist, 2 if branch does not exist, leaf info if all went well
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_leaf_on_tree`;
DELIMITER $$


CREATE Procedure `create_leaf_on_tree` (
    in t VARCHAR(64),
    in n VARCHAR(45)
)
BEGIN
DECLARE treeid INT;
DECLARE branchid INT;
select id into treeid from tree where token = t;
IF (treeid) THEN
    select id into branchid from branch where tree_id = treeid;
    IF (branchid) THEN
        insert into `annotree`.`leaf` (name, branch_id)
        values (n, branchid);
        set @id = LAST_INSERT_ID();
        select 'id', 'name', 'description', 'owner_user_id', 'branch_id', 'created_at'
        union 
        select id, name, description, owner_user_id, branch_id, created_at 
        from leaf 
        where id = @id;
    ELSE
        select '2';
    END IF;
ELSE
    select '1';
END IF;
END $$ 
DELIMITER ; $$
