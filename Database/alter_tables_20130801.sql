USE annotree;

ALTER TABLE user
ADD signup_date TIMESTAMP NULL
AFTER status;

ALTER TABLE user
ADD last_login TIMESTAMP NULL
AFTER signup_date;

COMMIT;
