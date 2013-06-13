-- --------------------------------------------------------------------------------
-- update_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION `update_user`(
  u VARCHAR(45),
  p VARCHAR(40), 
  fn VARCHAR(45),
  lastn VARCHAR(45),
  e VARCHAR(255),
  lan VARCHAR(3),
  t VARCHAR(15),
  pip VARCHAR(45)) RETURNS INT
BEGIN
update `annotree`.`user` set
  password = p , first_name = fn, last_name = lastn, email  = e, lang = lan, time_zone = t, profile_image_path = pip  where
username = u and e REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}'; 
return ROW_COUNT();
END
