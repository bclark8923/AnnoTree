-- -----------------------------------------------------
-- Table `annotree`.`group_user`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`group_user` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`group_user` (
  `group_id` INT NOT NULL,
  `user_id` INT NOT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `fk_groupUser_1` (`group_id` ASC) ,
  INDEX `fk_groupUser_2` (`user_id` ASC) ,
  PRIMARY KEY (`group_id`, `user_id`) ,
  CONSTRAINT `fk_groupUser_1`
    FOREIGN KEY (`group_id` )
    REFERENCES `annotree`.`group` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_groupUser_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


