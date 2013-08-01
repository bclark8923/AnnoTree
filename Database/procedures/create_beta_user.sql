-- --------------------------------------------------------------------------------
-- create_beta_user
-- returns 0 - success
-- otherwise returns error:
-- 1 - existing beta user, allowed to sign up
-- 2 - invited user, can sign up
-- 3 - already an active User
-- 4 - already signed up for the beta
-- 5 - invalid email
-- --------------------------------------------------------------------------------
drop procedure IF EXISTS `create_beta_user`;
DELIMITER $$


CREATE procedure `create_beta_user`(
  emailin VARCHAR(255)
)
BEGIN
set @status = (select status from user where email = emailin);
If (@status = 3) THEN
    select '3';
ELSEIF (@status = 2) THEN
    select '2';
ELSEIF (@status = 1) THEN
    select '1';
ELSEIF (@status = 0) THEN
    select '4';
ELSE
    IF emailin REGEXP '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}' THEN
        insert into user (email, status) values (emailin, 0);
        select '0';
    ELSE 
        select '5';
    END IF;
END IF;
END $$
delimiter ; $$
