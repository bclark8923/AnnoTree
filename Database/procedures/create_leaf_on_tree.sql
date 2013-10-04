 -- --------------------------------------------------------------------------------
 -- create_leaf_on_tree
 -- creates a leaf on a tree with a single branch (used for iOS uploads)
 -- returns 1 if tree does not exist, 2 if branch does not exist, leaf info if all went well
 -- --------------------------------------------------------------------------------
 use annotree;
 drop  procedure IF EXISTS `create_leaf_on_tree`;
 DELIMITER $$
 
 
 CREATE Procedure `create_leaf_on_tree` (
     in t VARCHAR(64),
-    in n VARCHAR(512)
+    in n VARCHAR(45)
 )
 BEGIN
 DECLARE treeid INT;
 DECLARE treeowner INT;
 DECLARE branchid INT;
 select id, owner_id into treeid, treeowner from tree where token = t;
 IF (treeid) THEN
     select id into branchid from branch where tree_id = treeid
         AND name = 'User Feedback';
     UPDATE leaf SET priority = priority + 1
         WHERE branch_id = branchid;     
     IF (branchid) THEN
         insert into `annotree`.`leaf` (name, branch_id, owner_user_id, priority)
         values (n, branchid, treeowner, 1);
         set @id = LAST_INSERT_ID();
         select 'id', 'name', 'owner_user_id', 'branch_id', 'created_at'
         union 
