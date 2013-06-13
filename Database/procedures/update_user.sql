-- --------------------------------------------------------------------------------
-- update_user
-- Note: You need to salt the password in perl.
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION `update_user`(
  p VARCHAR(40), 
  fn VARCHAR(45),
  lastn VARCHAR(45),
  e VARCHAR(255),
  lan VARCHAR(3),
  t VARCHAR(15),
  pip VARCHAR(45)) RETURNS INT
BEGIN
update `annotree`.`user` set
  password = p , first_name = fn, last_name = lastn, lang = lan, time_zone = t, profile_image_path = pip  where email = e; 
return ROW_COUNT();
END
