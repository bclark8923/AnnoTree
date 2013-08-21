-- --------------------------------------------------------------------------------
-- delete_user_from_tree
-- returns failure 3 - del_user is forest_owner
--         failure 2 - req_user does not have permissions
--         failure 1 - del_user does not belong to the tree
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `delete_user_from_tree`;
DELIMITER $$

CREATE PROCEDURE `delete_user_from_tree`(
    IN treeid INT,
    IN del_user INT,
    IN req_user INT
)
BEGIN
IF (SELECT ut.id FROM user_tree ut WHERE ut.user_id = req_user AND ut.tree_id = treeid) THEN
    SET @forest_owner = (SELECT f.owner_id 
                         FROM forest AS f 
                            INNER JOIN tree AS t ON t.forest_id = f.id
                         WHERE t.id = treeid);
    IF (@forest_owner = del_user) THEN
        SELECT '3';
    ELSE
        DELETE FROM user_tree WHERE user_id = del_user AND tree_id = treeid;
        IF row_count() = 1 THEN
            IF (SELECT id FROM tree WHERE id = treeid AND owner_id = del_user) THEN
                UPDATE tree SET owner_id = @forest_owner
                    WHERE id = treeid;
            END IF;
            SELECT '0';
        ELSE 
          SELECT '1';
        END IF;
    END IF;
ELSE
    SELECT '2';
END IF;
END $$
DELIMITER ; $$
