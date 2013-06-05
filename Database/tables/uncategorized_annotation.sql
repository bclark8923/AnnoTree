-- -----------------------------------------------------
-- Table `annotree`.`uncategorized_annotation`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


CREATE  TABLE IF NOT EXISTS `annotree`.`uncategorized_annotation` (
  `id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_uncategorized_annotation_1` (`id` ASC) ,
  CONSTRAINT `fk_uncategorized_annotation_1`
    FOREIGN KEY (`id` )
    REFERENCES `annotree`.`annotation` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

