-- -----------------------------------------------------
-- Table `annotree`.`task`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`task` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`task` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NULL ,
  `description` VARCHAR(1024) NULL ,
  `status` INT NULL ,
  `leaf_id` INT NULL ,
  `tree_id` INT,
  `assigned_to` INT NULL,
  `due_date` TIMESTAMP null,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) ,
  INDEX `fk_task_1` (`leaf_id` ASC),
  INDEX `fk_task_2` (`assigned_to` ASC),
  INDEX `fk_task_3` (`tree_id` ASC), 
  CONSTRAINT `fk_task_1`
    FOREIGN KEY (`leaf_id` )
    REFERENCES `annotree`.`leaf` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_task_2`
    FOREIGN KEY (`assigned_to` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_task_3`
    Foreign key ('tree_id')
    references `annotree`.`tree` (`id`)
    on delete no action
    on update no action
)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

