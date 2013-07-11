use annotree;
drop  procedure IF EXISTS `get_users_in_shared_trees`;
DELIMITER $$


CREATE Procedure `get_users_in_shared_trees`(
    in user_in int
)
BEGIN
    select distinct ut2.user_id from user_tree as ut 
                  inner join user_tree as ut2 
                      on ut.tree_id = ut2.tree_id
    where ut.user_id = user_in;
END $$
delimiter ; $$
