-- --------------------------------------------------------------------------------
-- create_default_branches
-- returns  0 - success
--          1 - error: user does not have permissions
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_default_branches`;
DELIMITER $$

CREATE PROCEDURE `create_default_branches` (
    IN user_id_in INT,
    IN tree_id_in INT
)
BEGIN
IF (SELECT id FROM user_tree WHERE user_id = user_id_in AND tree_id = tree_id_in) THEN
        INSERT INTO branch (tree_id, name) VALUES (tree_id_in, 'User Feedback');
        INSERT INTO branch (name, tree_id) VALUES ('Bugs', tree_id_in);
        SET @branch_id = LAST_INSERT_ID();
        INSERT INTO branch (name, tree_id) VALUES ('New', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '1');
        INSERT INTO branch (name, tree_id) VALUES ('In Progress', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '2');
        INSERT INTO branch (name, tree_id) VALUES ('Complete', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '3');
        INSERT INTO branch (name, tree_id) VALUES ('Product Backlog', tree_id_in);
        SET @branch_id = LAST_INSERT_ID();
        INSERT INTO branch (name, tree_id) VALUES ('New', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '1');
        INSERT INTO branch (name, tree_id) VALUES ('In Progress', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '2');
        INSERT INTO branch (name, tree_id) VALUES ('Complete', tree_id_in);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '3');
        INSERT INTO branch (tree_id, name) VALUES (tree_id_in, 'Archive');
        SELECT '0';
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
