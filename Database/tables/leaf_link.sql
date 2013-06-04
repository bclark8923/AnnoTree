-- -----------------------------------------------------
-- Table `annotree`.`leaf_link`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`leaf_link` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`leaf_link` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `source` INT NULL ,
  `destination` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_leafLink_1` (`source` ASC) ,
  INDEX `fk_leaf_link_2` (`destination` ASC) ,
  CONSTRAINT `fk_leafLink_1`
    FOREIGN KEY (`source` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_leaf_link_2`
    FOREIGN KEY (`destination` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

