-- --------------------------------------------------------------------------------
-- create_leaf
-- returns  success - leaf information
--          1 - error: user does not have permission
--          2 - error: branch does not exist
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_leaf`;
DELIMITER $$

CREATE PROCEDURE `create_leaf`(
    IN name_in VARCHAR(512),
    IN owner_user_id_in INT,
    IN branch_id_in INT
  )
BEGIN
IF (SELECT ut.id FROM user_tree AS ut JOIN branch AS b ON b.tree_id = ut.tree_id 
    WHERE ut.user_id = owner_user_id_in AND b.id = branch_id_in) THEN
    IF (SELECT id FROM branch WHERE id = branch_id_in) THEN
        IF (SELECT id FROM branch_link WHERE destination_branch_id = branch_id_in) THEN
            SET @priority = (SELECT MAX(priority) FROM leaf
                WHERE branch_id = branch_id_in);
            IF (@priority IS NULL) THEN
                SET @priority = 0;
            END IF;
        ELSE
            SET @priority = 0;
            UPDATE leaf SET priority = priority + 1 
                WHERE branch_id = branch_id_in;
        END IF;
        INSERT INTO `annotree`.`leaf` 
            (name, owner_user_id, branch_id, priority)
            VALUES (name_in, owner_user_id_in, branch_id_in, @priority + 1);
        SET @leaf_id = LAST_INSERT_ID();
        -- TODO improve this
        SELECT 'id', 'name', 'owner_user_id', 'branch_id', 'created_at', 'priority'
            UNION 
            SELECT id, name, owner_user_id, branch_id, created_at, priority 
            FROM leaf 
            WHERE id = @leaf_id;
    ELSE 
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
delimiter ; $$
