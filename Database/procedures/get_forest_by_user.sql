-- --------------------------------------------------------------------------------
-- get_forest_by_user
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop function IF EXISTS `get_user`;
DELIMITER $$

CREATE PROCEDURE `get_forest_by_user`(
  in u INT)
BEGIN
DECLARE forest_data varchar(1024) default '0';
select id, name, description, created_at
            from forest
            where id in (
                select forest_id
                from user_forest
                where user_id = u
            );
END $$
delimiter ; $$
