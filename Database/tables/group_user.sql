-- -----------------------------------------------------
-- Table `annotree`.`group_user`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`group_user` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`group_user` (
  `group` INT NOT NULL AUTO_INCREMENT,
  `user` INT NOT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `fk_groupUser_1` (`group` ASC) ,
  INDEX `fk_groupUser_2` (`user` ASC) ,
  PRIMARY KEY (`group`, `user`) ,
  CONSTRAINT `fk_groupUser_1`
    FOREIGN KEY (`group` )
    REFERENCES `annotree`.`group` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_groupUser_2`
    FOREIGN KEY (`user` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


