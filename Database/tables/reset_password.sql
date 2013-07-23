-- -----------------------------------------------------
-- Table `annotree`.`reset_password`
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=`TRADITIONAL`;

DROP TABLE IF EXISTS `annotree`.`reset_password` ;

CREATE TABLE IF NOT EXISTS `annotree`.`reset_password` (
  `email` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `hash` VARCHAR(64) NULL,
  PRIMARY KEY (`email`),
  INDEX `fk_email` (`email` ASC),
  CONSTRAINT `fk_email`
    FOREIGN KEY (`email`)
    REFERENCES `annotree`.`user` (`email`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
