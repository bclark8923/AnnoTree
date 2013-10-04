-- --------------------------------------------------------------------------------
-- get_annotations_files_by_leaf
-- returns the annotation file locations on disk for annotations associated with a leaf
-- --------------------------------------------------------------------------------
USE annotree;
DROP PROCEDURE IF EXISTS `get_annotations_files_by_leaf`;
DELIMITER $$

CREATE Procedure `get_annotations_files_by_leaf`(
    IN leafid INT
)
BEGIN
    SELECT filename_disk FROM annotation WHERE leaf_id = leafid and active = 1;
END $$
delimiter ; $$
