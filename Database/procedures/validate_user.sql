-- --------------------------------------------------------------------------------
-- validate_user
-- returns the user's password if the user exists
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `validate_user`;
DELIMITER $$

CREATE procedure `validate_user`(
  e VARCHAR(255))
BEGIN
select id, password
            from user 
            where email = e
            and active = true;
END $$
delimiter ; $$
