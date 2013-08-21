-- --------------------------------------------------------------------------------
-- access_annotation - verifies that the user has access to view the annoation
-- returns 1 if true 0 if not
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `access_annotation`;
DELIMITER $$

CREATE PROCEDURE `access_annotation` (
    IN user_id_in INT,
    IN anno_id_in INT 
)
BEGIN
DECLARE usercheck INT;
DECLARE filename VARCHAR(128);
SELECT a.id INTO usercheck, a.filename_disk INTO filename
    FROM annotation AS a  
        INNER JOIN leaf AS l ON a.leaf_id = l.id
        INNER JOIN branch AS b ON b.id = l.branch_id
        INNER JOIN user_tree AS u ON b.tree_id = u.tree_id
    WHERE a.id = anno_id_in
        AND u.user_id = user_id_in;
IF (usercheck) THEN
    SELECT '1', filename;
ELSE
    SELECT '0';
END IF;
END $$
DELIMITER ; $$
