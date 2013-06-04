-- -----------------------------------------------------
-- Table `annotree`.`comment`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`comment` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`comment` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `comment` VARCHAR(1024) NULL ,
  `user` INT NULL ,
  `created_at` DATETIME NULL ,
  `leaf` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_comment_1` (`leaf` ASC) ,
  INDEX `fk_comment_2` (`user` ASC) ,
  CONSTRAINT `fk_comment_1`
    FOREIGN KEY (`leaf` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_2`
    FOREIGN KEY (`user` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

