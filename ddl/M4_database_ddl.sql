-- ============================================================================
-- AMUSEMENT PARK MANAGEMENT SYSTEM
-- Milestone 1.5 — Database Setup (DDL Scripts)
-- 
-- Author      : Haleema Gohar | BSSE(A) 4th Semester
-- Submitted To: Sir Ali Hassan
-- Institute   : Institute of Management Sciences, Peshawar
-- Version     : 1.5 
-- ============================================================================
-- -----------------------------------------------------
-- Version Control Table
-- ------------------------------------------------------------------------------------------------------------------
-- Version | Milestone         | Description                                                            | Status
-- --------|-------------------|------------------------------------------------------------------------|-----------
-- 1.0     | Project Proposal  | Initial proposal of Amusement Park DBMS with problem statement...      | Completed
-- 1.1     | Schema            | Complete relational schema design, tables, keys, constraints...        | Completed
-- 1.2     | ERD Diagram       | Entity Relationship Diagram showing table relationships...             | Completed
-- 1.3     | Normalization     | Normalized Schema & ERD Optimization. Removed email, visit_date...     | Completed
-- 1.4     | Dataset & Dataflow| Preprocessed synthetic datasets and organized system dataflow map...   | Completed
-- 1.5     | Database Setup    | Implemented physical DDL script schema setup with keys and indexes.    | Completed
-- ------------------------------------------------------------------------------------------------------------------


SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema amusement_park
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `amusement_park`;
CREATE SCHEMA IF NOT EXISTS `amusement_park` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `amusement_park` ;

-- -----------------------------------------------------
-- Table `amusement_park`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`customers` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`customer_id`),
  CONSTRAINT `chk_customer_phone` CHECK (`phone` REGEXP '^[0-9+\\-() ]{7,20}$')
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `amusement_park`.`rides`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`rides` (
  `ride_id` INT NOT NULL AUTO_INCREMENT,
  `ride_name` VARCHAR(100) NOT NULL,
  `ride_type` VARCHAR(50) NOT NULL,
  `min_capacity` INT NOT NULL DEFAULT 1,
  `max_capacity` INT NOT NULL,
  `price_per_round` DECIMAL(8,2) NOT NULL,
  `status` ENUM('Active', 'Maintenance', 'Closed') NOT NULL DEFAULT 'Active',
  `description` VARCHAR(255) NULL,
  PRIMARY KEY (`ride_id`),
  UNIQUE INDEX `ride_name` (`ride_name` ASC) VISIBLE,
  CONSTRAINT `chk_ride_capacity` CHECK (`max_capacity` >= `min_capacity` AND `min_capacity` >= 1),
  CONSTRAINT `chk_ride_price` CHECK (`price_per_round` >= 0.00)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `amusement_park`.`revenue`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`revenue` (
  `revenue_id` INT NOT NULL AUTO_INCREMENT,
  `ride_id` INT NOT NULL,
  `rev_date` DATE NOT NULL,
  `earnings` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `source` ENUM('Booking', 'Walk-in', 'Group', 'Event') NOT NULL DEFAULT 'Booking',
  PRIMARY KEY (`revenue_id`),
  UNIQUE INDEX `uq_rev_ride_date` (`ride_id` ASC, `rev_date` ASC) VISIBLE,
  CONSTRAINT `fk_rev_ride`
    FOREIGN KEY (`ride_id`)
    REFERENCES `amusement_park`.`rides` (`ride_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_revenue_earnings` CHECK (`earnings` >= 0.00)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `amusement_park`.`ride_bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`ride_bookings` (
  `booking_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `ride_id` INT NOT NULL,
  `booked_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `num_riders` INT NOT NULL DEFAULT '1',
  `amount_paid` DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (`booking_id`),
  INDEX `fk_booking_customer` (`customer_id` ASC) VISIBLE,
  INDEX `fk_booking_ride` (`ride_id` ASC) VISIBLE,
  CONSTRAINT `fk_booking_customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `amusement_park`.`customers` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_booking_ride`
    FOREIGN KEY (`ride_id`)
    REFERENCES `amusement_park`.`rides` (`ride_id`)
    ON DELETE RESTRICT -- Enforces data safety (cannot delete a ride if active bookings exist)
    ON UPDATE CASCADE,
  CONSTRAINT `chk_booking_riders` CHECK (`num_riders` >= 1),
  CONSTRAINT `chk_booking_amount` CHECK (`amount_paid` >= 0.00)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `amusement_park`.`ride_operations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`ride_operations` (
  `operation_id` INT NOT NULL AUTO_INCREMENT,
  `ride_id` INT NOT NULL,
  `op_date` DATE NOT NULL,
  `total_rounds` INT NOT NULL DEFAULT '0',
  `total_customers` INT NOT NULL DEFAULT '0',
  PRIMARY KEY (`operation_id`),
  UNIQUE INDEX `uq_ride_date` (`ride_id` ASC, `op_date` ASC) VISIBLE,
  CONSTRAINT `fk_op_ride`
    FOREIGN KEY (`ride_id`)
    REFERENCES `amusement_park`.`rides` (`ride_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_ops_rounds` CHECK (`total_rounds` >= 0),
  CONSTRAINT `chk_ops_customers` CHECK (`total_customers` >= 0)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `amusement_park`.`tickets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `amusement_park`.`tickets` (
  `ticket_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `ticket_type` ENUM('Adult', 'Child', 'Senior', 'Student') NOT NULL,
  `price` DECIMAL(8,2) NOT NULL,
  `valid_date` DATE NOT NULL,
  PRIMARY KEY (`ticket_id`),
  INDEX `fk_ticket_customer` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_ticket_customer`
    FOREIGN KEY (`customer_id`)
    REFERENCES `amusement_park`.`customers` (`customer_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_ticket_price` CHECK (`price` >= 0.00)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- -----------------------------------------------------
-- Performance Optimization Indexes (For High-Frequency Queries)
-- -----------------------------------------------------
CREATE INDEX `idx_tickets_date` ON `amusement_park`.`tickets` (`valid_date`);
CREATE INDEX `idx_bookings_date` ON `amusement_park`.`ride_bookings` (`booked_at`);
CREATE INDEX `idx_revenue_date` ON `amusement_park`.`revenue` (`rev_date`);

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;