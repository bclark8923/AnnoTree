

drop procedure IF EXISTS `get_user_name_tree_name`;
DELIMITER $$

CREATE procedure `get_user_name_tree_name`(
    in userid int,
    in treeid int
)
BEGIN
select u.first_name, u.last_name, t.name from user as u
    left join user_tree as ut
    on ut.user_id = u.id
    left join tree as t
    on ut.tree_id = t.id
    where u.id = userid
    and ut.tree_id = treeid;
END $$
delimiter ; $$
