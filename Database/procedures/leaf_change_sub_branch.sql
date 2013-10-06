-- --------------------------------------------------------------------------------
-- leaf_change_sub_branch
-- returns  0 - success
--          1 - error: user does not have permissions
--          2 - error: branch does not exist
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `leaf_change_sub_branch`;
DELIMITER $$

CREATE PROCEDURE `leaf_change_sub_branch` (
    IN user_id_in INT,
    IN tree_id_in INT,
    IN new_branch INT,
    IN leaf_id_in INT,
    IN old_branch INT,
    IN new_priority INT,
    IN old_priority INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
    IF (SELECT id FROM branch WHERE id = new_branch AND tree_id = tree_id_in) THEN
        IF (new_branch = old_branch) THEN
            IF (new_priority > old_priority) THEN
                UPDATE leaf SET priority = priority - 1
                    WHERE priority >= old_priority
                    AND priority <= new_priority
                    AND branch_id = new_branch;
            ELSE
                UPDATE leaf SET priority = priority + 1
                    WHERE priority <= old_priority
                    AND priority >= new_priority
                    AND branch_id = new_branch;
            END IF;
            UPDATE leaf SET priority = new_priority
                WHERE id = leaf_id_in;
            SELECT '0';
        ELSE
            UPDATE leaf SET priority = priority + 1 
                WHERE priority >= new_priority
                AND branch_id = new_branch;
            UPDATE leaf SET priority = new_priority,
                branch_id = new_branch
                WHERE id = leaf_id_in;
            UPDATE leaf SET priority = priority - 1
                WHERE priority > old_priority
                AND branch_id = old_branch;
        END IF;
        SELECT '0';
    ELSE
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
