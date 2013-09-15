-- --------------------------------------------------------------------------------
-- rename_leaf
-- returns  0 - success
--          1 - error: user does not have permissions
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `rename_leaf`;
DELIMITER $$

CREATE PROCEDURE `rename_leaf` (
   IN leaf_id_in INT,
   IN name_in VARCHAR(512),
   IN req_user INT
)
BEGIN
IF (SELECT ut.id FROM user_tree AS ut
    JOIN branch AS b ON b.tree_id = ut.tree_id
    JOIN leaf AS l ON l.branch_id = b.id
    WHERE l.id = leaf_id_in
    AND ut.user_id = req_user
) THEN
    UPDATE leaf 
        SET leaf.name = name_in
        WHERE leaf.id = leaf_id_in;
    SELECT '0';
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
