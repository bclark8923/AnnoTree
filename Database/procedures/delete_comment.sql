-- --------------------------------------------------------------------------------
-- delete_comment
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_comment`;
DELIMITER $$


CREATE Procedure `delete_comment`(
  in user INT,
  in comment_id INT
  )
BEGIN
set @update_timeout = 15;
SET FOREIGN_KEY_CHECKS=0;
delete c 
        from `comment` as c 
        inner join user as u on
            c.user_id = user and
            u.active = true
            and u.id = c.user_id
    where
        c.id = comment_id and
	minute(current_timestamp()) - minute(c.created_at) < @update_timeout;
Set @updated = ROW_COUNT();
if @updated = 1 then
select '1';
elseif (select minute(current_timestamp()) - minute(c.created_at) > @update_timeout from comment as c) then
select '2', concat('More than ', @update_timeout, ' minutes have passed');
else
select '0';
end if;
SET FOREIGN_KEY_CHECKS=1;
END $$
delimiter ; $$
