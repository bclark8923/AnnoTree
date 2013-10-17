-- --------------------------------------------------------------------------------
-- update_notifications
-- returns  0 - success
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `update_notifications`;
DELIMITER $$

CREATE PROCEDURE `update_notifications`(
    IN user_id_in INT,
    IN tree_invite INT,
    IN leaf_assign INT
)
BEGIN
UPDATE user SET notf_tree_invite = tree_invite,
    notf_leaf_assign = leaf_assign
    WHERE id = user_id_in;
END $$
DELIMITER ; $$
