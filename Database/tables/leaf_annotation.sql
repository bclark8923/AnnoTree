-- -----------------------------------------------------
-- Table `annotree`.`leaf_annotation`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`leaf_annotation` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`leaf_annotation` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `leaf_id` INT NULL ,
  `annotation_id` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_leaf_annotation_1` (`annotation_id` ASC) ,
  INDEX `fk_leaf_annotation_2` (`leaf_id` ASC) ,
  CONSTRAINT `fk_leaf_annotation_1`
    FOREIGN KEY (`annotation_id` )
    REFERENCES `annotree`.`annotation` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_leaf_annotation_2`
    FOREIGN KEY (`leaf_id` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


