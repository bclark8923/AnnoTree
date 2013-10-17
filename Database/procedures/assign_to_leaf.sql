-- --------------------------------------------------------------------------------
-- assign_to_leaf
-- returns  0 - success: returns if the assignee wants to be notified or not
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
            SET @branch = (SELECT source_branch_id FROM branch_link
                WHERE destination_branch_id = (SELECT branch_id FROM leaf
                    WHERE id = leaf_id_in));
            IF (@branch IS NULL) THEN
                SELECT 'req_user_fname', 'req_user_lname', 'assign_fname', 'assign_lname', 'assign_status', 'assign_email', 'assign_notf_leaf_assign', 'forest_id', 'tree_id', 'branch_id', 'leaf_id', 'leaf_name'
                    UNION
                    SELECT req.first_name, req.last_name, assign_user.first_name, assign_user.last_name, assign_user.status, assign_user.email, assign_user.notf_leaf_assign, f.id, t.id, b.id, l.id, l.name
                    FROM forest AS f 
                    JOIN tree AS t ON t.forest_id = f.id
                    JOIN branch AS b ON b.tree_id = t.id
                    JOIN leaf AS l ON l.branch_id = b.id
                    JOIN user_tree AS assign_ut ON assign_ut.tree_id = t.id
                    JOIN user AS assign_user ON assign_user.id = assign_ut.user_id
                    JOIN user_tree AS req_ut ON req_ut.tree_id = t.id
                    JOIN user AS req ON req.id = req_ut.user_id
                    WHERE l.id = leaf_id_in
                    AND assign_user.id = assign
                    AND req.id = req_user;
            ELSE
                SELECT 'req_user_fname', 'req_user_lname', 'assign_fname', 'assign_lname', 'assign_status', 'assign_email', 'assign_notf_leaf_assign', 'forest_id', 'tree_id', 'branch_id', 'leaf_id', 'leaf_name'
                    UNION
                    SELECT req.first_name, req.last_name, assign_user.first_name, assign_user.last_name, assign_user.status, assign_user.email, assign_user.notf_leaf_assign, f.id, t.id, @branch, l.id, l.name
                    FROM forest AS f 
                    JOIN tree AS t ON t.forest_id = f.id
                    JOIN branch AS b ON b.tree_id = t.id
                    JOIN leaf AS l ON l.branch_id = b.id
                    JOIN user_tree AS assign_ut ON assign_ut.tree_id = t.id
                    JOIN user AS assign_user ON assign_user.id = assign_ut.user_id
                    JOIN user_tree AS req_ut ON req_ut.tree_id = t.id
                    JOIN user AS req ON req.id = req_ut.user_id
                    WHERE l.id = leaf_id_in
                    AND assign_user.id = assign
                    AND req.id = req_user;
            END IF;
        END IF;
    ELSE 
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
