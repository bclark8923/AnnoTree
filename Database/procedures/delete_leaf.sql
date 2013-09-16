-- --------------------------------------------------------------------------------
-- delete_leaf
-- returns  0 - success
--          1 - error: nothing was deleted
--          2 - error: user does not have permission to delete that leaf
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `delete_leaf`;
DELIMITER $$

CREATE PROCEDURE `delete_leaf`(
    IN req_user INT,
    IN leaf_id_in INT
)
BEGIN
DECLARE del_priority INT;
DECLARE del_branch INT;
IF (SELECT ut.id FROM user_tree AS ut
    JOIN branch AS b ON b.tree_id = ut.tree_id
    JOIN leaf AS l ON l.branch_id = b.id
    WHERE l.id = leaf_id_in
    AND ut.user_id = req_user
) THEN
    SET FOREIGN_KEY_CHECKS=0;
    SELECT priority, branch_id INTO del_priority, del_branch
        FROM leaf 
        WHERE id = leaf_id_in;
    UPDATE leaf SET priority = priority - 1
        WHERE priority > del_priority
        AND branch_id = del_branch;
    DELETE l, a, la
        FROM leaf AS l 
        LEFT OUTER JOIN annotation AS a ON l.id = a.leaf_id
        LEFT OUTER JOIN leaf_assignments AS la ON l.id = la.leaf_id
        WHERE l.id = leaf_id_in;
    IF (ROW_COUNT() > 0) THEN
        SELECT '0';
        SET FOREIGN_KEY_CHECKS=1;
    ELSE 
        SELECT '1';
    END IF;
ELSE
    SELECT '2';
END IF;
END $$
DELIMITER ; $$
