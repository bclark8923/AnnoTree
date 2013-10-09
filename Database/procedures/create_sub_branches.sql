-- --------------------------------------------------------------------------------
-- create_sub_branches
-- returns  0 - success: returns all sub-branches' info
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_sub_branches`;
DELIMITER $$

CREATE PROCEDURE `create_sub_branches` (
    IN branch_id_in INT,
    IN tree_id_in INT
)
BEGIN
INSERT INTO branch (name, tree_id) VALUES ('New', tree_id_in);
SET @sub_branch_id = LAST_INSERT_ID();
INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
    VALUES (branch_id_in, @sub_branch_id, '1');
INSERT INTO branch (name, tree_id) VALUES ('In Progress', tree_id_in);
SET @sub_branch_id = LAST_INSERT_ID();
INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
    VALUES (branch_id_in, @sub_branch_id, '2');
INSERT INTO branch (name, tree_id) VALUES ('Complete', tree_id_in);
SET @sub_branch_id = LAST_INSERT_ID();
INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
    VALUES (branch_id_in, @sub_branch_id, '3');
SELECT 'id', 'name', 'tree_id', 'description', 'created_at', 'priority'
    UNION
    SELECT b.id, b.name, b.tree_id, b.description, b.created_at, priority
    FROM branch AS b JOIN branch_link AS bl ON b.id = bl.destination_branch_id
    WHERE bl.source_branch_id = branch_id_in;
END $$
DELIMITER ; $$
