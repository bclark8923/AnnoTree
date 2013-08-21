-- --------------------------------------------------------------------------------
-- create_user
-- Note: You need to salt the password in perl.
-- returns 0 - success, 1 - emails fails regex, 2 - email already exists, 3 - not granted access yet
-- STATUS CODES
-- 0 - Inactive Beta User
-- 1 - Beta User, can sign up
-- 2 - Invited User, can sign up
-- 3 - Active User 
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `create_user`;
DELIMITER $$

CREATE PROCEDURE `create_user`(
    IN password VARCHAR(128), 
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN email VARCHAR(255),
    IN lang VARCHAR(3),
    IN time_zone VARCHAR(15),
    IN profile_image_path VARCHAR(45),
    IN token_in VARCHAR(64),
    IN created_in TIMESTAMP,
    IN services VARCHAR(128)
)
BEGIN
SET @status = (SELECT user.status FROM user WHERE email = user.email);
If (@status and @status != 1) THEN
    IF (@status = 3) THEN
        SELECT '2'; 
    ELSEIF (@status = 2) THEN
    UPDATE user SET 
        user.status = 3, 
        user.password = password, 
        user.first_name = first_name, 
        user.last_name = last_name, 
        user.lang = lang, 
        user.time_zone = time_zone, 
        user.profile_image_path = profile_image_path,
        user.signup_date = NOW()
        where user.email = email;
    select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
    union
     select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where email = user.email;  
  end if;
ELSEIF (@status = 0) THEN
    SELECT '6';
ELSEIF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
    IF (@status = 1) THEN
        UPDATE user SET 
            user.status = 3, 
            user.password = password, 
            user.first_name = first_name, 
            user.last_name = last_name, 
            user.lang = lang, 
            user.time_zone = time_zone, 
            user.profile_image_path = profile_image_path,
            user.signup_date = NOW()
            where user.email = email;
        set @user_id = (SELECT id FROM user WHERE user.email = email);
    ELSE
        insert into `annotree`.`user`
            (password, first_name, last_name, email, lang, time_zone, profile_image_path, status, signup_date) 
            values 
            (password, first_name, last_name, email, lang, time_zone, profile_image_path, 3, NOW());
        set @user_id = LAST_INSERT_ID();
    END IF;
    --TODO: Revert this back to calling the stored procedures @name is a session variable.
    select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
    union
    select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where id = @user_id;
        SET @name = concat(first_name, ' ', last_name);
        INSERT INTO forest (name, owner_id) VALUES (concat(@name, '\'s Forest'), @user_id);
        SET @forest_id = LAST_INSERT_ID();
        INSERT INTO user_forest (user_id, forest_id) VALUES (@user_id, @forest_id);
        INSERT INTO tree (name, logo, owner_id, token, created_at, forest_id) VALUES (concat(@name,  '\'s Tree'), 'img/logo.png', @user_id, token_in, created_in, @forest_id);
        SET @tree_id = LAST_INSERT_ID();
        INSERT INTO user_tree (user_id, tree_id) VALUES (@user_id, @tree_id);
        INSERT INTO branch (name, tree_id) VALUES (concat(@name, '\'s Branch'), @tree_id);
        SET @branch_id = LAST_INSERT_ID();
        INSERT INTO leaf (name, owner_user_id, branch_id) VALUES (concat(@name, '\'s Leaf'), @user_id, @branch_id);
        SET @leaf_id = LAST_INSERT_ID();
        INSERT INTO annotation (mime_type, filename, filename_disk, leaf_id, meta_system, meta_version, meta_model, meta_vendor, meta_orientation)
            VALUES ('image/png', 'anno_default.png', 'anno_default.png', @leaf_id, 'iOS', '6', 'Phone', 'Apple', 'Portrait');
        set @anno_id = LAST_INSERT_ID();
        update annotation set path = concat(services, @anno_id) where id = @anno_id;
    commit;
ELSE
    select '1';
END IF;
END $$
delimiter ; $$
