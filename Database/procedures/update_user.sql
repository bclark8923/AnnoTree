-- --------------------------------------------------------------------------------
-- update_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
drop procedure if exists `update_user`;
DELIMITER $$

CREATE procedure `update_user`(
  p VARCHAR(40), 
  fn VARCHAR(45),
  lastn VARCHAR(45),
  e VARCHAR(255),
  lan VARCHAR(3),
  t VARCHAR(15),
  pip VARCHAR(45))
BEGIN
update `annotree`.`user` set
  password = p , first_name = fn, last_name = lastn, lang = lan, time_zone = t, profile_image_path = pip  where email = e; 
select 'id', 'password', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'active' 
union
select * from user where email = e;
END
