-- --------------------------------------------------------------------------------
-- update_tree
-- On success - returns a 0 if tree was updated, 1 if tree stayed the same
-- On error - returns a 2 if tree does not exist
--          - returns a 3 if user does not have permission to that tree
-- --------------------------------------------------------------------------------
drop procedure if exists `update_tree`;
DELIMITER $$

CREATE procedure `update_tree`(
    in `treeid` INT,
    in `name` VARCHAR(45),
    in `description` VARCHAR(1024),
    in req_user INT
)
BEGIN
IF (select t.id from tree t where t.id = treeid) THEN
    IF (select id from user_tree where user_id = req_user and tree_id = treeid) THEN
        update tree as t set
        t.name = name, 
        t.description = description
        where t.id = treeid;
        if ROW_COUNT() > 0 then 
            select '0';
        else
            select '1'; 
        end if;
    ELSE
        select '3';
    END IF;
ELSE 
    select '2';
END IF;
END $$
DELIMITER ; $$
