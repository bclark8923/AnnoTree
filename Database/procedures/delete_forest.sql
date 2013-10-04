-- --------------------------------------------------------------------------------
-- delete_forest
-- returns 0 - success
-- returns 1 - user does not have permissions to delete that forest or forest does not exist
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_forest`;
DELIMITER $$


CREATE Procedure `delete_forest`(
  in req_user INT,
  in forestid INT
  )
BEGIN
IF (select id from user_forest where user_id = req_user and forest_id = forestid) then
  SET FOREIGN_KEY_CHECKS=0; 
    update forest as f
        join user_forest as uf
            on uf.forest_id = f.id
     set active = 0
      where
          f.id = forestid and
          uf.user_id = req_user;
  SET FOREIGN_KEY_CHECKS=1;
select '0';
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
