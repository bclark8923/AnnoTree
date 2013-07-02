-- --------------------------------------------------------------------------------
-- delete_forest
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_forest`;
DELIMITER $$


CREATE Procedure `delete_forest`(
  in user INT,
  in forest_id INT
  )
BEGIN
IF (select id from user where id = user) then
  SET FOREIGN_KEY_CHECKS=0;
  -- TODO: leafs
  delete f, uf, t, ut, b, ub, l, ul a 
          from forest as f 
           left join user_forest as uf on
              uf.forest_id = f.id
           left join tree as t on
              t.forest_id = f.id
           left join user_tree as ut on
              ut.tree_id = t.id
           left join branch as b on
              b.tree_id = t.id
           left join user_branch as ub on
              ub.branch_id = b.id
           left join leaf as l on
              l.branch_id = b.id
           left join user_leaf as ul on
              l.id = ul.leaf_id
           left join annotation as a on
              a.leaf_id = l.id            
      where
          f.id = forest_id and
          uf.user_id = user;
  SET FOREIGN_KEY_CHECKS=1;
  -- this does not work if there are not entries in every table!
  --  if row_count() > 0 then select '0';
  --  else select '1';
  -- end if;
select '0';
END IF;
END $$
delimiter ; $$
