-- -----------------------------------------------------
-- Table `annotree`.`user_forest`
-- -----------------------------------------------------

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`user_forest` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`user_forest` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL ,
  `forest_id` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_user_forest_1` (`user_id` ASC) ,
  INDEX `fk_user_forest_2` (`forest_id` ASC) ,
  CONSTRAINT `fk_user_forest_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_forest_2`
    FOREIGN KEY (`forest_id` )
    REFERENCES `annotree`.`forest` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

