USE annotree;

DROP PROCEDURE IF EXISTS delete_comment;
DROP PROCEDURE IF EXISTS update_comment;
DROP PROCEDURE IF EXISTS add_tree_token;
DROP PROCEDURE IF EXISTS create_task;
DROP PROCEDURE IF EXISTS get_tasks_by_tree;
DROP PROCEDURE IF EXISTS get_annotations_by_leaf;
DROP PROCEDURE IF EXISTS get_leafs;
DROP PROCEDURE IF EXISTS get_branches_and_leafs;
DROP PROCEDURE IF EXISTS delete_branch;
DROP PROCEDURE IF EXISTS activate_user;
DROP PROCEDURE IF EXISTS update_user;
DROP PROCEDURE IF EXISTS update_task;

DROP TABLE IF EXISTS path;
DROP TABLE IF EXISTS group_user;
DROP TABLE IF EXISTS `annotree`.`group`;
DROP TABLE IF EXISTS leaf_version;
DROP TABLE IF EXISTS leaf_annotation;
DROP TABLE IF EXISTS uncategorized_annotation;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS task_statuses;


alter table annotation add column active bool not null default 1;
alter table branch add column active bool not null default 1;
alter table forest add column active bool not null default 1;
alter table leaf add column active bool not null default 1;
alter table leaf_comment add column active bool not null default 1;
alter table tree add column active bool not null default 1;

