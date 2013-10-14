-- ------------------------------------------------------------------------------
-- create_leaf_comment
-- success - returns comment information
-- error - returns 1 if user does not have permissions or tree/branch/leaf does not exist
-- --------------------------------------------------------------------------------
USE annotree;
DROP  PROCEDURE IF EXISTS `create_leaf_comment`;
DELIMITER $$

CREATE PROCEDURE `create_leaf_comment` (
    IN user_in INT,
    IN comment_in VARCHAR(1024),
    IN leaf_id_in INT
)
BEGIN
IF (SELECT ut.id 
    FROM user_tree AS ut INNER JOIN branch AS b ON b.tree_id = ut.tree_id 
    INNER JOIN leaf AS l ON l.branch_id = b.id 
    WHERE l.id = leaf_id_in 
    AND ut.user_id = user_in) THEN
    INSERT INTO leaf_comment 
        (user_id, `comment`, leaf_id, updated_at)
        VALUES (user_in, comment_in, leaf_id_in, NOW());
    set @id = LAST_INSERT_ID();
    SELECT 'id', 'comment', 'created_at', 'updated_at', 'first_name', 'last_name', 'profile_image_path'
        UNION
        SELECT lc.id, lc.`comment`, lc.created_at, lc.updated_at, u.first_name, u.last_name, u.profile_image_path
        FROM leaf_comment AS lc INNER JOIN `user` AS u ON lc.user_id = u.id
        WHERE leaf_id = leaf_id_in;
ELSE 
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
