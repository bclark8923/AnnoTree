-- -----------------------------------------------------
-- Table `annotree`.`organization`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`forest`;

CREATE  TABLE IF NOT EXISTS `annotree`.`forest` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL ,
  `description` VARCHAR(1024) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `owner_id` INT NULL,
  `active` bool not null default 1,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

