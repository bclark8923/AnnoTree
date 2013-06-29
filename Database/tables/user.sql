-- -----------------------------------------------------
-- Table `annotree`.`user`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `annotree`.`user` ;

CREATE  TABLE IF NOT EXISTS `annotree`.`user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `password` VARCHAR(128), 
  `first_name` VARCHAR(45) NULL ,
  `last_name` VARCHAR(45) NULL ,
  `email` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `lang` VARCHAR(3) NULL ,
  `time_zone` VARCHAR(15) NULL ,
  `profile_image_path` VARCHAR(45) NULL ,
  `status` INTEGER NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`(255))
 )
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
