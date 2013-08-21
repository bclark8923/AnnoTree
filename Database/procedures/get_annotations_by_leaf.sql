-- --------------------------------------------------------------------------------
-- get_annotations_by_leaf
-- returns the annotation path for annotations associated with a leaf
-- TODO: should there be a check?
-- --------------------------------------------------------------------------------
use annotree;
drop  procedure IF EXISTS `get_annotations_by_leaf`;
DELIMITER $$


CREATE Procedure `get_annotations_by_leaf`(
    in leafid INT
)
BEGIN
    select path from annotation where leaf_id = leafid;
END $$
delimiter ; $$
