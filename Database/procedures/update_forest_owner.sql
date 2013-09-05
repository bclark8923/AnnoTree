-- --------------------------------------------------------------------------------
-- update_forest_owner
-- on success - returns new owner's email
-- on error - returns 1 if requesting user does not have permissions on that forest
--            returns 2 if new owner does not have permissions on that forest
--            returns 3 if new owner is already the owner for the forest
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `update_forest_owner`;
DELIMITER $$

CREATE PROCEDURE `update_forest_owner` (
    IN fid_in INT,
    IN req_user INT,
    IN new_owner INT
)
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE treeid INT;
DECLARE tree_cur CURSOR FOR SELECT id FROM tree WHERE forest_id = fid_in;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
IF (SELECT id FROM user_forest WHERE user_id = req_user AND forest_id = fid_in) THEN
    IF (SELECT id FROM user_forest WHERE user_id = new_owner AND forest_id = fid_in) THEN
        SET @cur_forest_owner = (SELECT owner_id FROM forest WHERE id = fid_in);
        IF (@cur_forest_owner = new_owner) THEN
            SELECT '3';
        ELSE
            UPDATE forest
                SET owner_id = new_owner
                WHERE id = fid_in;
            OPEN tree_cur;
            update_loop: LOOP
                FETCH tree_cur INTO treeid;
                IF (done) THEN
                    LEAVE update_loop;
                END IF;
                SET @utcheck = (SELECT id FROM user_tree WHERE tree_id = treeid AND user_id = new_owner);
                IF (@utcheck IS NULL) THEN
                    INSERT INTO user_tree (user_id, tree_id) VALUES (new_owner, treeid);
                END IF;
            END LOOP;
            CLOSE tree_cur;
            SELECT 'id', 'email', 'first_name', 'last_name'
                UNION
                SELECT id, email, first_name, last_name FROM user WHERE id = new_owner;
        END IF;
    ELSE
        SELECT '2';
    END IF;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
