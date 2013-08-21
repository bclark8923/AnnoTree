-- --------------------------------------------------------------------------------
-- add_user_to_tree
-- On success - returns 2 if new user, 3 if existing user, 0 if the user is already added to the tree
-- On failure - returns 1 (requsting user doesn't have permissions on that tree)
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `add_user_to_tree`;
DELIMITER $$


CREATE Procedure `add_user_to_tree`(
    in treeid int,
    in email_in varchar(255),
    in requesting_user INT
)
BEGIN
IF (select id from user_tree where tree_id = treeid and user_id = requesting_user) THEN
  set @user_to_add = (select id from user where user.email = email_in);  
    START TRANSACTION;  
    IF @user_to_add THEN       
        IF (SELECT id FROM user_tree WHERE tree_id = treeid AND user_id = @user_to_add) THEN
            SELECT '0'; 
        ELSE
            insert into user_tree (user_id, tree_id) values (@user_to_add, treeid);
            IF (SELECT uf.id 
                    FROM tree AS t 
                        INNER JOIN user_forest AS uf ON t.forest_id = uf.forest_id
                    WHERE t.id = treeid AND uf.user_id = @user_to_add)
            THEN
                    SET @status = (SELECT status FROM user WHERE id = @user_to_add);
            ELSE
                insert into user_forest(user_id, forest_id) 
                  select @user_to_add, tree.forest_id from tree where tree.id = treeid;
            END IF;
            SET @status = (SELECT status FROM user WHERE id = @user_to_add);
            IF (@status = 0 OR @status = 1) THEN
                UPDATE user SET status = 2 WHERE id = @user_to_add;
                SELECT 'status'
                    UNION
                    SELECT '2';
            ELSE 
                SELECT 'status'
                    UNION
                    SELECT '3';
            END IF;
        
        END IF;
    ELSE
        --TODO: call create_user or have this do regex check in here
        insert into user(email, status) values (email_in, 2);
        set @new_user_id = LAST_INSERT_ID();
        insert into user_tree (user_id, tree_id) values (@new_user_id, treeid);
         insert into user_forest(user_id, forest_id) 
          select @new_user_id, tree.forest_id from tree where tree.id = treeid;
        
        select 'status' union
        select '2';
    
    END IF;
    COMMIT;
ELSE
    SELECT '1';
END IF;
END $$
delimiter ; $$
