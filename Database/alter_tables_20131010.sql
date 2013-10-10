USE annotree;

ALTER TABLE branch_link
ADD COLUMN active BOOL NOT NULL DEFAULT 1;
