-- -----------------------------------------------------
-- Table `annotree`.`branch`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;


DROP TABLE IF EXISTS `annotree`.`branch` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`branch` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `tree_id` INT NULL,
  `description` VARCHAR(1024) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) ,
  INDEX `fk_branch_1` (`tree_id` ASC) ,
  CONSTRAINT `fk_branch_1`
    FOREIGN KEY (`tree_id` )
    REFERENCES `annotree`.`tree` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
