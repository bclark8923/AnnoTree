-- --------------------------------------------------------------------------------
-- get_annotations_by_forest
-- returns the annotation path for annotations associated with a forest
-- --------------------------------------------------------------------------------

use annotree;
drop  procedure IF EXISTS `get_annotations_by_forest`;
DELIMITER $$


CREATE Procedure `get_annotations_by_forest`(
  in req_user INT,
  in forestid INT
)
BEGIN
IF (select id from user_forest where user_id = req_user and forest_id = forestid) then
    select a.path
      from forest as f 
       left join user_forest as uf on
          uf.forest_id = f.id
          and f.active = 1
       inner join tree as t on
          t.forest_id = f.id
          and t.active = 1
       left join user_tree as ut on
          ut.tree_id = t.id
       inner join branch as b on
          b.tree_id = t.id
       inner join leaf as l on
          l.branch_id = b.id and
          l.active = 1
       inner join annotation as a on
          a.leaf_id = l.id
          and a.active = 1            
      where
          f.id = forestid and
          uf.user_id = req_user;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
