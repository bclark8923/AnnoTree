-- --------------------------------------------------------------------------------
-- get_forest_by_user
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop function IF EXISTS `get_user`;
DELIMITER $$

CREATE FUNCTION `get_forest_by_user`(
  u INT
)
returns INT, VARCHAR(45), VARCHAR(1024), TIMESTAMP
BEGIN
DECLARE forest_data varchar(1024) default '0';
SET @forest_data = (select id, name, description, created_at
            from forest
            where id in (
                select forest_id
                from user_forest
                where user_id = u
            ));
return @forest_data;
END $$
delimiter ; $$
