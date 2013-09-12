USE annotree;

UPDATE branch SET name = 'User Feedback';
UPDATE branch SET description = NULL;

ALTER TABLE leaf
MODIFY name VARCHAR(512);


ALTER TABLE leaf
ADD priority INT NULL
AFTER branch_id;

ALTER TABLE branch_link
ADD priority INT NOT NULL
AFTER destination_branch_id;
/* uncomment for push to dev*/
-- add new branches to trees
DROP PROCEDURE IF EXISTS new_branches;
DELIMITER $$
CREATE PROCEDURE new_branches()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE treeid INT;
    DECLARE tree_cur CURSOR FOR SELECT id FROM tree;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN tree_cur;
    update_loop: LOOP
        FETCH tree_cur INTO treeid;
        IF (done) THEN
            LEAVE update_loop;
        END IF;
        INSERT INTO branch (name, tree_id) VALUES ('Bugs', treeid);
        SET @branch_id = LAST_INSERT_ID();
        INSERT INTO branch (name, tree_id) VALUES ('New', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '1');
        INSERT INTO branch (name, tree_id) VALUES ('In Progress', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '2');
        INSERT INTO branch (name, tree_id) VALUES ('Complete', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '3');
        INSERT INTO branch (name, tree_id) VALUES ('Product Backlog', treeid);
        SET @branch_id = LAST_INSERT_ID();
        INSERT INTO branch (name, tree_id) VALUES ('New', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '1');
        INSERT INTO branch (name, tree_id) VALUES ('In Progress', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '2');
        INSERT INTO branch (name, tree_id) VALUES ('Complete', treeid);
        SET @sub_branch_id = LAST_INSERT_ID();
        INSERT INTO branch_link (source_branch_id, destination_branch_id, priority) 
            VALUES (@branch_id, @sub_branch_id, '3');
    END LOOP;
    CLOSE tree_cur;
END $$
DELIMITER ; $$

CALL new_branches;
DROP PROCEDURE IF EXISTS new_branches;
