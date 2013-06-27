-- -----------------------------------------------------
-- Table `annotree`.`branch_link`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`branch_link` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`branch_link` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `source_branch_id` INT NULL ,
  `destination_branch_id` INT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) ,
  INDEX `fk_branchLink_1` (`source_branch_id` ASC) ,
  INDEX `fk_branch_link_2` (`destination_branch_id` ASC) ,
  CONSTRAINT `fk_branchLink_1`
    FOREIGN KEY (`source_branch_id` )
    REFERENCES `annotree`.`branch` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_branch_link_2`
    FOREIGN KEY (`destination_branch_id` )
    REFERENCES `annotree`.`branch` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

