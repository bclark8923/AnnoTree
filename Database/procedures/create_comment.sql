--   `id` INT NOT NULL AUTO_INCREMENT ,
--  `comment` VARCHAR(1024) NULL ,
--  `user_id` INT NULL ,
--  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--  `leaf_id` INT NULL,

-- --------------------------------------------------------------------------------
-- create_comment
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `create_comment`;
DELIMITER $$


CREATE Procedure `create_comment`(
  in user INT,
  in c varchar(1024),
  in leaf_id INT
  )
BEGIN
IF (select id from user where id = user and active = true) and (select id from leaf where id = leaf_id) then
insert into `annotree`.`comment` 
  (user_id, `comment`, leaf_id)
  values (user, c, leaf_id);
set @id = LAST_INSERT_ID();

select 'id', 'comment', 'user_id', 'created_at', 'leaf_id' 
union 
select * from comment where id = @id;

END IF;
END $$
delimiter ; $$
