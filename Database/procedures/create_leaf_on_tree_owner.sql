-- --------------------------------------------------------------------------------
-- create_leaf_on_tree_owner - creates a leaf (used for chrome upload)
-- returns  success - leaf info
--          1 - error: user does not have permissions
--          2 - error: branch does not exist
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_leaf_on_tree_owner`;
DELIMITER $$

CREATE Procedure `create_leaf_on_tree_owner` (
    in t VARCHAR(64),
    in n VARCHAR(45),
    IN owner_email VARCHAR(255)
)
BEGIN
DECLARE treeid INT;
DECLARE ownerid INT;
DECLARE branchid INT;
select id into treeid from tree where token = t;
SELECT id INTO ownerid FROM user WHERE email = owner_email;
IF (SELECT id FROM user_tree WHERE tree_id = treeid AND user_id = ownerid) THEN
    select id into branchid from branch where tree_id = treeid
        AND name = 'User Feedback';
    UPDATE leaf SET priority = priority + 1
        WHERE branch_id = branchid;
    IF (branchid) THEN
        insert into `annotree`.`leaf` (name, branch_id, owner_user_id, priority)
        values (n, branchid, ownerid, 1);
        set @id = LAST_INSERT_ID();
        select 'id', 'name', 'owner_user_id', 'branch_id', 'created_at'
        union 
        select id, name, owner_user_id, branch_id, created_at 
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
