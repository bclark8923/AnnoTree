-- -----------------------------------------------------
-- Table `annotree`.`annotation`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`annotation` ;

CREATE TABLE IF NOT EXISTS `annotree`.`annotation` (
    `id` INT NOT NULL AUTO_INCREMENT ,
    `mime_type` VARCHAR(128) NULL ,
    `path` VARCHAR(1024) NULL ,
    `filename` VARCHAR(128) NULL ,
    `filename_disk` VARCHAR(128) NULL ,
    `leaf_id` INT,
    `created_by` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `site_url` VARCHAR(2048),
    `meta_system` VARCHAR(128),
    `meta_version` VARCHAR(128),
    `meta_model` VARCHAR(128),
    `meta_vendor` VARCHAR(128),
    `meta_orientation` VARCHAR(128),
    `active` bool not null default 1,
    PRIMARY KEY (`id`),
    INDEX `fk_annotation_1` (`leaf_id` ASC),
    CONSTRAINT `fk_annotation_1` FOREIGN KEY (`leaf_id`) REFERENCES `leaf` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


