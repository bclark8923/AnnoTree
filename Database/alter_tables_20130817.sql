USE annotree;

ALTER TABLE annotation
ADD created_by INT NULL
AFTER leaf_id;

ALTER TABLE annotation
ADD site_url VARCHAR(2048)
AFTER created_at;

COMMIT;
