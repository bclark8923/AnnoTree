-- -----------------------------------------------------
-- Table `annotree`.`leaf_version`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`leaf_version` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`leaf_version` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL ,
  `comment` VARCHAR(1024) NULL ,
  `owner_user_id` INT NULL ,
  `tree_id` INT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `version` INT NOT NULL,
  PRIMARY KEY (`version`, `id`) ,
  INDEX `fk_leaf_1` (`tree_id` ASC) ,
  INDEX `fk_leaf_3` (`owner_user_id` ASC) ,
  INDEX `fk_leaf_version_1` (`id` ASC) ,
  CONSTRAINT `fk_leaf_version_4`
    FOREIGN KEY (`tree_id` )
    REFERENCES `annotree`.`tree` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_leaf_version_2`
    FOREIGN KEY (`owner_user_id` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_leaf_version_1`
    FOREIGN KEY (`id` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

