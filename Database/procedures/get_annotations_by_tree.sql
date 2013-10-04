-- --------------------------------------------------------------------------------
-- get_annotations_by_tree
-- returns the annotation path for annotations associated with a tree
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_annotations_by_tree`;
DELIMITER $$


CREATE Procedure `get_annotations_by_tree`(
  in req_user INT,
  in treeid INT
)
BEGIN
IF (select id from user_tree where user_id = req_user and tree_id = treeid) then
    select a.path 
    from tree as t
       left join user_tree as ut on
          ut.tree_id = t.id
       left join branch as b on
          b.tree_id = t.id
       left join leaf as l on
          l.branch_id = b.id
       left join annotation as a on
          a.leaf_id = l.id            
      where
          t.id = treeid and
          ut.user_id = req_user and
          l.active = 1;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
