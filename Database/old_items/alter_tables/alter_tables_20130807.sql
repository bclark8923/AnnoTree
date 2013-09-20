USE annotree;

ALTER TABLE forest
ADD owner_id INT NULL
AFTER created_at;

COMMIT;
