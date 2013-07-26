-- --------------------------------------------------------------------------------
-- create_user
-- Note: You need to salt the password in perl.
-- returns 0 - success, 1 - emails fails regex, 2 - email already exists
-- STATUS CODES
-- 0 - Inactive Beta User
-- 1 - Beta User, can sign up
-- 2 - Invited User, can sign up
-- 3 - Active User 
-- --------------------------------------------------------------------------------
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
If (@status) THEN
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
        user.profile_image_path = profile_image_path where user.email = email;
    select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
    union
     select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where email = user.email;  
  end if;
ELSEIF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
insert into `annotree`.`user`
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, status) 
values 
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, 3);
set @user_id = LAST_INSERT_ID();
select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
union
select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where id = @user_id;
  set @name = concat(first_name, ' ', last_name);
  call create_forest (@user_id, concat(@name, '\'s Forest'),  'This is a sample forest.');
  call create_tree(@user_id, @forest_id, concat(@name,  '\'s Tree'), 'This is a sample tree.','img/logo.png', token_in, created_in);
  call create_branch(@user_id, @tree_id, concat(@name, '\'s Branch'), 'This is a sample branch.');
  call create_leaf(concat(@name, '\'s Leaf'), 'This is a sample leaf.', @user_id, @branch_id);
  call create_annotation('image/png', services, 'anno_default.png', @leaf_id);
set @anno_id = LAST_INSERT_ID();
update annotation set path = concat(services, @anno_id) where id = @anno_id;
commit;

ELSE
select '1';
END IF;
END $$
delimiter ; $$
