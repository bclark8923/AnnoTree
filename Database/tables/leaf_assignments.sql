-- -----------------------------------------------------
-- Table `annotree`.`leaf_assignments`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`leaf_assignments`;

CREATE TABLE IF NOT EXISTS `annotree`.`leaf_assignments` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NULL,
    `leaf_id` INT NULL,
    PRIMARY KEY (`id`) ,
    INDEX `fk_leaf_assignment_1` (`user_id` ASC) ,
    INDEX `fk_leaf_assignment_2` (`leaf_id` ASC) ,
    CONSTRAINT `fk_leaf_assignment_1`
        FOREIGN KEY (`user_id`)
        REFERENCES `annotree`.`user` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT `fk_leaf_id_2`
        FOREIGN KEY (`leaf_id`)
        REFERENCES `annotree`.`leaf` (`id`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
