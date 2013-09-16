-- --------------------------------------------------------------------------------
-- delete_forest
-- returns 0 - success
-- returns 1 - user does not have permissions to delete that forest or forest does not exist
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_forest`;
DELIMITER $$


CREATE Procedure `delete_forest`(
  in req_user INT,
  in forestid INT
  )
BEGIN
IF (select id from user_forest where user_id = req_user and forest_id = forestid) then
  SET FOREIGN_KEY_CHECKS=0;
  delete f, uf, t, ut, b, l, a, la
          from forest as f 
           left join user_forest as uf on
              uf.forest_id = f.id
           left join tree as t on
              t.forest_id = f.id
           left join user_tree as ut on
              ut.tree_id = t.id
           left join branch as b on
              b.tree_id = t.id
           left join leaf as l on
              l.branch_id = b.id
           left join annotation as a on
              a.leaf_id = l.id
            LEFT JOIN leaf_assignments AS la ON
            la.leaf_id = l.id
      where
          f.id = forestid and
          uf.user_id = req_user;
  SET FOREIGN_KEY_CHECKS=1;
select '0';
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
