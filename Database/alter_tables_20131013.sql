USE annotree;

ALTER TABLE user
MODIFY COLUMN profile_image_path VARCHAR(256);

ALTER TABLE user
ADD notf_tree_invite BOOL NOT NULL DEFAULT 1
AFTER last_login;

ALTER TABLE user
ADD notf_leaf_assign BOOL NOT NULL DEFAULT 1
AFTER notf_tree_invite;
