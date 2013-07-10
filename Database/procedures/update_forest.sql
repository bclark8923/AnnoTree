-- --------------------------------------------------------------------------------
-- update_forest
-- On success - return 0 if forest was updated, 1 if nothing was changed
-- On failure - returns 2 if user does not have permission to forest or forest does not exist
-- --------------------------------------------------------------------------------
drop procedure if exists `update_forest`;
DELIMITER $$

CREATE procedure `update_forest`(
    in `forestid` INT,
    in `name` VARCHAR(45),
    in `description` VARCHAR(1024),
    in req_user INT
)
BEGIN
IF (select id from user_forest uf where user_id = req_user and forest_id = forestid) THEN
    update forest as f set
    f.name = name, 
    f.description = description
    where f.id = forestid;
    if ROW_COUNT() > 0 then 
        select '0';
    else
        select '1'; 
    end if;
ELSE
    select '2';
END IF;
END $$
delimiter ; $$
