-- --------------------------------------------------------------------------------
-- create_forest
-- returns 0 - success
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_forest`;
DELIMITER $$

CREATE PROCEDURE `create_forest`(
    IN userid_in INT,
    IN n VARCHAR(45),
    IN d VARCHAR(1024)
)
BEGIN
IF (SELECT id FROM user WHERE id = userid_in) THEN
    INSERT INTO `annotree`.`forest`
        (name, description, owner_id)
        values (n, d, userid_in);
        SET @id = LAST_INSERT_ID();
    INSERT INTO `annotree`.`user_forest`
        (user_id, forest_id)
        VALUES
        (userid_in, @id);
    SELECT 'id', 'name', 'description', 'created_at', 'owner'
        UNION
        SELECT f.id, f.name, f.description, f.created_at, u.email
        FROM forest AS f INNER JOIN user AS u ON u.id = f.owner_id
        WHERE f.id = @id;
ELSE
    SELECT '1';
END IF;
END $$
DELIMITER ; $$
