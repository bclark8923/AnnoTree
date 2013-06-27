-- -----------------------------------------------------
-- Table `annotree`.`annotation`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`annotation` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`annotation` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `mime_type` VARCHAR(45) NULL ,
  `path` VARCHAR(45) NULL ,
  `leaf_id` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_annotation_1` (`leaf_id` ASC),
  CONSTRAINT `fk_annotation_1` FOREIGN KEY (`leaf_id`) REFERENCES `leaf` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
 )
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


