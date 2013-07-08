-- --------------------------------------------------------------------------------
-- delete_tree
-- returns 0 - success
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `delete_tree`;
DELIMITER $$


CREATE Procedure `delete_tree`(
  in user INT,
  in tree_id INT
  )
BEGIN
IF (select id from user where id = user) then
  SET FOREIGN_KEY_CHECKS=0;
  -- TODO: leafs
  delete t, ut, b, l, a from
          tree as t
           left join user_tree as ut on
              ut.tree_id = t.id
           left join branch as b on
              b.tree_id = t.id
           left join leaf as l on
              l.branch_id = b.id
           left join annotation as a on
              a.leaf_id = l.id            
      where
          t.id = tree_id and
          ut.user_id = user;
  SET FOREIGN_KEY_CHECKS=1;
  -- this does not work if there are not entries in every table!
  --  if row_count() > 0 then select '0';
  --  else select '1';
  -- end if;
select '0';
END IF;
END $$
delimiter ; $$
