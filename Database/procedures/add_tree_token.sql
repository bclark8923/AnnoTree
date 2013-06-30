-- --------------------------------------------------------------------------------
-- get_annotation
-- returns ??
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `add_tree_token`;
DELIMITER $$


CREATE Procedure `add_tree_token` (
    in t varchar(64),
    in treeid INT
)
BEGIN
update tree
set token = t
where id = treeid;
END $$
delimiter ; $$
