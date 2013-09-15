-- --------------------------------------------------------------------------------
-- leaf_change_branch
-- returns  0 - success
--          1 - error: user does not have permissions
--          2 - error: branch does not exist
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `leaf_change_branch`;
DELIMITER $$

CREATE PROCEDURE `leaf_change_branch` (
    IN user_id_in INT,
    IN tree_id_in INT,
    IN branch_id_in INT,
    IN leaf_id_in INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
    IF (SELECT id FROM branch WHERE id = branch_id_in AND tree_id = tree_id_in) THEN
        SET @old_priority = (SELECT priority FROM leaf WHERE id = leaf_id_in);
        SET @old_branch = (SELECT branch_id FROM leaf WHERE id = leaf_id_in);
        UPDATE leaf SET priority = priority - 1
            WHERE priority > @old_priority
            AND branch_id = @old_branch;
        IF (SELECT id FROM branch_link WHERE source_branch_id = branch_id_in AND priority = '1') THEN
            SET @priority = (SELECT MAX(priority) FROM leaf
                WHERE branch_id = 
                    (SELECT destination_branch_id FROM branch_link 
                        WHERE source_branch_id = branch_id_in 
                        AND priority = '1'));
            IF (@priority IS NULL) THEN
                SET @priority = 0;
            END IF;
            UPDATE leaf SET branch_id = 
                (SELECT destination_branch_id FROM branch_link 
                    WHERE source_branch_id = branch_id_in 
                    AND priority = '1'), 
                priority = (@priority + 1)
                WHERE id = leaf_id_in;
        ELSE
            SET @priority = (SELECT MAX(priority) FROM leaf
                WHERE branch_id = branch_id_in);
            IF (@priority IS NULL) THEN
                SET @priority = 0;
            END IF;
            UPDATE leaf SET branch_id = branch_id_in,
                priority = @priority + 1
                WHERE id = leaf_id_in;
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
