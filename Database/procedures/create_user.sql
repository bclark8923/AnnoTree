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
drop procedure IF EXISTS `create_user`;
DELIMITER $$


CREATE procedure `create_user`(
  password VARCHAR(128), 
  first_name VARCHAR(45),
  last_name VARCHAR(45),
  email VARCHAR(255),
  lang VARCHAR(3),
  time_zone VARCHAR(15),
  profile_image_path VARCHAR(45),
  status Tinyint
)
BEGIN
set @status = (select user.status from user where email = user.email);
If (@status) then
  if (@status = 3) then select '2'; 
  ELSEIF (@status = 2) then
    update user set user.status = 3, user.password = password, user.first_name = first_name, user.last_name = last_name, user.lang = lang, user.time_zone = time_zone, user.profile_image_path = profile_image_path where user.email = email;
    select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
    union
     select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where email = user.email;  
  end if;
ELSEIF email REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' then
insert into `annotree`.`user`
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, status) 
values 
  (password, first_name, last_name, email, lang, time_zone, profile_image_path, status);
set @user_id = LAST_INSERT_ID();
select 'id', 'first_name', 'last_name', 'email', 'created_at', 'lang', 'time_zone', 'profile_image_path', 'status' 
union
select id, first_name, last_name, email, created_at, lang, time_zone, profile_image_path, status from user where id = @user_id;
if status = 3 then
  set @name = concat(first_name, ' ', last_name);
  call create_forest (@user_id, concat(@name, '\'s Forest'),  'This is a sample forest.');
  call create_tree(@user_id, @forest_id, concat(@name,  '\'s Tree'), 'This is a sample tree.','img/logo.png');
  call create_branch(@user_id, @tree_id, concat(@name, '\'s Branch'), 'This is a sample branch.');
  call create_leaf(concat(@name, '\'s Leaf'), 'This is a sample leaf.', @user_id, @branch_id);
end if;

ELSE
select '1';
END IF;
END $$
delimiter ; $$
