-- --------------------------------------------------------------------------------
-- delete_branch
-- returns  success: returns the file path of the annotations to be deleted
--          1 - error: users does not have permission
--          2 - error: can't delete 'User Feedback' branch
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `delete_branch`;
DELIMITER $$

CREATE PROCEDURE `delete_branch`(
    IN req_user INT,
    IN tree_id_in INT,
    IN branch_id_in INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = req_user AND tree_id = tree_id_in) THEN
    SET @name = (SELECT name FROM branch WHERE id = branch_id_in);
    IF (@name = 'User Feedback') THEN
        SELECT '2';
    ELSE
        UPDATE branch AS b LEFT JOIN leaf AS l ON b.id = l.branch_id
            LEFT JOIN annotation AS a ON l.id = a.leaf_id
            LEFT JOIN branch_link AS bl ON b.id = bl.source_branch_id
            LEFT JOIN branch AS b2 ON b2.id = bl.destination_branch_id
            LEFT JOIN leaf AS l2 ON l2.branch_id = b2.id
            LEFT JOIN annotation AS a2 ON a2.leaf_id = l2.id
            SET b.active = 0, l.active = 0, a.active = 0,
            bl.active = 0, b2.active = 0, l2.active = 0, a2.active = 0
            WHERE
            b.id = branch_id_in;
        SELECT 'filename_disk'
            UNION
            SELECT a.filename_disk
            FROM branch AS b INNER JOIN leaf AS l ON b.id = l.branch_id
            INNER JOIN annotation AS a on l.id = a.leaf_id
            WHERE b.id = branch_id_in
            UNION
            SELECT a2.filename_disk
            FROM branch AS b INNER JOIN branch_link AS bl ON b.id = bl.source_branch_id
            INNER JOIN branch AS b2 ON b2.id = bl.destination_branch_id
            INNER JOIN leaf AS l2 ON l2.branch_id = b2.id
            INNER JOIN annotation AS a2 ON a2.leaf_id = l2.id
            WHERE b.id = branch_id_in;
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
