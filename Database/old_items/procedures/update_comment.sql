-- --------------------------------------------------------------------------------
-- update_comment
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `update_comment`;
DELIMITER $$


CREATE Procedure `update_comment`(
  in user INT,
  in comment_id INT,
  in c varchar(1024)
  )
BEGIN
set @update_timeout = 15;
SET FOREIGN_KEY_CHECKS=0;
update `comment` set `comment`.c = c, `comment`.updated_at = now() where 
        `comment`.id = comment_id and
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
