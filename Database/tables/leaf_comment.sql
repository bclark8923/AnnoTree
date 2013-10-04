-- -----------------------------------------------------
-- Table `annotree`.`comment`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`leaf_comment` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`leaf_comment` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `comment` VARCHAR(2048) NULL ,
  `user_id` INT NULL ,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP null,
  `leaf_id` INT NULL,
  `active` bool not null default 1,
  PRIMARY KEY (`id`) ,
  INDEX `fk_comment_1` (`leaf_id` ASC) ,
  INDEX `fk_comment_2` (`user_id` ASC) ,
  CONSTRAINT `fk_comment_1`
    FOREIGN KEY (`leaf_id` )
    REFERENCES `annotree`.`leaf` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comment_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `annotree`.`user` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

