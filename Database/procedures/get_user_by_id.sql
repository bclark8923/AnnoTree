-- --------------------------------------------------------------------------------
-- get_user
-- returns the information for an individual user
-- TODO: See if this is needed check get_user
-- --------------------------------------------------------------------------------
use annotree;
drop procedure IF EXISTS `get_user_by_id`;
DELIMITER $$

CREATE procedure `get_user_by_id`(
    idin INT
)
BEGIN
    select 'first_name', 'last_name', 'email'
    union
    select first_name, last_name, email
    from user 
    where id = idin;
END $$
delimiter ; $$
