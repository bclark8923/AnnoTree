-- --------------------------------------------------------------------------------
-- remove_leaf_assignment
-- returns  0 - success
--          1 - error: requesting user does not have permission to assign to that leaf
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `remove_leaf_assignment`;
DELIMITER $$

CREATE PROCEDURE `remove_leaf_assignment`(
    IN req_user INT,
    IN leaf_id_in INT,
    IN remove INT
)
BEGIN
IF (SELECT ut.id FROM user_tree AS ut
    JOIN branch AS b ON b.tree_id = ut.tree_id
    JOIN leaf AS l ON l.branch_id = b.id
    WHERE l.id = leaf_id_in
    AND ut.user_id = req_user
) THEN
    DELETE FROM leaf_assignments 
        WHERE leaf_id = leaf_id_in
        AND user_id = remove;
    SELECT '0';
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
