-- --------------------------------------------------------------------------------
-- get_tree_name_from_token
-- returns tree name for an individual token
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_tree_name_from_token`;
DELIMITER $$

CREATE PROCEDURE `get_tree_name_from_token` (
    IN token_in VARCHAR(64)
)
BEGIN
    SELECT name
        FROM tree
        WHERE token = token_in;
END $$
DELIMITER ; $$;
