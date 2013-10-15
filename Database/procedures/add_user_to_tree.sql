 -- --------------------------------------------------------------------------------
 -- add_user_to_tree
 -- On success - returns 2 if new user, 3 if existing user
 -- On failure - returns 1 (requsting user doesn't have permissions on that tree)
 -- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `add_user_to_tree`;
DELIMITER $$
 
 
CREATE Procedure `add_user_to_tree`(
    in treeid int,
    in email_in varchar(255),
    in requesting_user INT,
    IN new_user_img VARCHAR(256)
)
 BEGIN
IF (select id from user_tree where tree_id = treeid and user_id = requesting_user) THEN
   set @user_to_add = (select id from user where user.email = email_in);  
   IF @user_to_add THEN
         START TRANSACTION;
         IF (SELECT id FROM user_tree WHERE tree_id = treeid AND user_id = @user_to_add) THEN
             SELECT '0'; 
         ELSE
             insert into user_tree (user_id, tree_id) values (@user_to_add, treeid);
             IF (SELECT uf.id FROM tree AS t INNER JOIN user_forest AS uf ON t.forest_id = uf.forest_id
                 WHERE t.id = treeid AND uf.user_id = @user_to_add) THEN
                     SET @status = (SELECT status FROM user WHERE id = @user_to_add);
             ELSE
                 insert into user_forest(user_id, forest_id) 
                   select @user_to_add, tree.forest_id from tree where tree.id = treeid;
             END IF;
             SET @status = (SELECT status FROM user WHERE id = @user_to_add);
             IF (@status = 0 OR @status = 1 OR @status = 2) THEN
                IF (@status = 0 OR @status = 1) THEN
                    UPDATE user SET invited_by = requesting_user WHERE id = @user_to_add;
                END IF;
                 UPDATE user SET status = 2 WHERE id = @user_to_add;
                 SELECT 'status'
                     UNION
                     SELECT '2';
             ELSE 
                 SELECT 'status'
                     UNION
                     SELECT '3';
             END IF;
         COMMIT;
         END IF;
     ELSE
       insert into user(email, status, profile_image_path, invited_by) values (email_in, 2, new_user_img, requesting_user);
         set @new_user_id = LAST_INSERT_ID();
         insert into user_tree (user_id, tree_id) values (@new_user_id, treeid);
          insert into user_forest(user_id, forest_id) 
           select @new_user_id, tree.forest_id from tree where tree.id = treeid;
         commit;
         select 'status' union
         select '2';
     END IF;
 ELSE
     select '1';
 END IF;
 END $$
 delimiter ; $$
