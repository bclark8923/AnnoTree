use annotree;

-- --------------------------------------------------------------------------------
-- delete_user 
-- return 0 on delete -1 on failure
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE FUNCTION `delete_user`(
  e VARCHAR(255)) RETURNS INT
BEGIN
update user set active = false where email = e;
return ROW_COUNT()-1;
END $$
delimiter ; $$
