USE annotree;

DROP PROCEDURE IF EXISTS archive_branch;
DELIMITER $$
CREATE PROCEDURE archive_branch()
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
        INSERT INTO branch (name, tree_id) VALUES ('Archive', treeid);
    END LOOP;
    CLOSE tree_cur;
END $$
DELIMITER ; $$

CALL archive_branch;
DROP PROCEDURE IF EXISTS archive_branch;

/*
DROP PROCEDURE IF EXISTS fix_uf_priority;
DELIMITER $$
CREATE PROCEDURE fix_uf_priority()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE branchid INT;
    DECLARE branch_cur CURSOR FOR SELECT id FROM branch WHERE name = 'User Feedback';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN branch_cur;
    update_loop: LOOP
        FETCH branch_cur INTO branchid;
        IF (done) THEN
            LEAVE update_loop;
        END IF;
        SET @priority = 1;
        block2: BEGIN
            DECLARE leafid INT;
            DECLARE done2 INT DEFAULT FALSE;
            DECLARE leaf_cur CURSOR FOR SELECT id FROM leaf WHERE branch_id = branchid ORDER BY id DESC;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
            OPEN leaf_cur;
            leaf_loop: LOOP
                FETCH leaf_cur INTO leafid;
                IF (done2) THEN
                    LEAVE leaf_loop;
                END IF;
                UPDATE leaf SET priority = @priority WHERE id = leafid;
                SET @priority = @priority + 1;
            END LOOP leaf_loop;
        END block2;
    END LOOP update_loop;
    CLOSE branch_cur;
END $$
DELIMITER ; $$

CALL fix_uf_priority;
DROP PROCEDURE IF EXISTS fix_uf_priority;
*/
