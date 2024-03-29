-- -----------------------------------------------------
-- Table `annotree`.`leaf`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`leaf` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`leaf` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(512) NULL ,
  `description` VARCHAR(1024) NULL ,
  `owner_user_id` INT NULL ,
  `branch_id` INT NULL ,
  `priority` INT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `active` bool not null default 1,
  PRIMARY KEY (`id`) ,
  INDEX `fk_leaf_1` (`branch_id` ASC),
  INDEX `fk_leaf_2` (`owner_user_id` ASC),
  CONSTRAINT `fk_leaf_1`
    FOREIGN KEY (`branch_id` )
    REFERENCES `annotree`.`branch` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_leaf_2`
    FOREIGN KEY (`owner_user_id` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

