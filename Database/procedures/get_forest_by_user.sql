-- --------------------------------------------------------------------------------
-- get_forest_by_user
-- Note: Returns a list of forest associated with a user's id
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_forest_by_user`;
DELIMITER $$

CREATE PROCEDURE `get_forest_by_user`(
  in u INT)
BEGIN
select 'id', 'name', 'description', 'created_at'
union
select forest.id, forest.name, forest.description, forest.created_at
            from forest
            join
                user_forest
                    on user_forest.forest_id = forest.id  
                    and user_forest.user_id = u;
set @id = LAST_INSERT_ID();
END $$
delimiter ; $$
