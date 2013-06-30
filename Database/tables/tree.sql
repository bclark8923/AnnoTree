-- -----------------------------------------------------
-- Table `annotree`.`project`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;


DROP TABLE IF EXISTS `annotree`.`tree` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`tree` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `forest_id` INT NULL,
  `description` VARCHAR(1024) NULL,
  `logo` VARCHAR(1024) NULL,
  `token` VARCHAR(64) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) ,
  INDEX `fk_project_1` (`forest_id` ASC) ,
  CONSTRAINT `fk_project_1`
    FOREIGN KEY (`forest_id` )
    REFERENCES `annotree`.`forest` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

