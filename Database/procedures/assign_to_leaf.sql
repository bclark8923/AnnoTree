-- --------------------------------------------------------------------------------
-- assign_to_leaf
-- returns  0 - success
--          1 - error: requesting user does not have permission to assign to that leaf
--          2 - error: assigned user does not have permission on that leaf
--          3 - error: assignment already exists
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `assign_to_leaf`;
DELIMITER $$

CREATE PROCEDURE `assign_to_leaf`(
    IN req_user INT,
    IN leaf_id_in INT,
    IN assign INT
)
BEGIN
IF (SELECT ut.id FROM user_tree AS ut
    JOIN branch AS b ON b.tree_id = ut.tree_id
    JOIN leaf AS l ON l.branch_id = b.id
    WHERE l.id = leaf_id_in
    AND ut.user_id = req_user
) THEN
    IF (SELECT ut.id FROM user_tree AS ut
        JOIN branch AS b ON b.tree_id = ut.tree_id
        JOIN leaf AS l ON l.branch_id = b.id
        WHERE l.id = leaf_id_in
        AND ut.user_id = assign
    ) THEN
        IF (SELECT id FROM leaf_assignments
            WHERE leaf_id = leaf_id_in
            AND user_id = assign
        ) THEN
            SELECT '3';
        ELSE
            INSERT INTO leaf_assignments (user_id, leaf_id)
                VALUES (assign, leaf_id_in);
            SELECT '0';
        END IF;
    ELSE 
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
