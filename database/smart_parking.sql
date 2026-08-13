-- Smart Parking Management System Database Schema
-- Generate complete working database structure and sample data

CREATE DATABASE IF NOT EXISTS `smart_parking`;
USE `smart_parking`;

-- 1. Users Table (Credentials & Roles)
CREATE TABLE IF NOT EXISTS `Users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) UNIQUE NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `role` ENUM('Admin', 'Attendant') NOT NULL DEFAULT 'Attendant',
  `status` ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_username` (`username`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Parking_Attendants Table (Profile Details)
CREATE TABLE IF NOT EXISTS `Parking_Attendants` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `address` TEXT,
  `hire_date` DATE NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Parking_Areas Table
CREATE TABLE IF NOT EXISTS `Parking_Areas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) UNIQUE NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `slot_count` INT NOT NULL DEFAULT 0,
  `base_price` DECIMAL(10, 2) NOT NULL DEFAULT 20.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_area_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Vehicles Table
CREATE TABLE IF NOT EXISTS `Vehicles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `license_plate` VARCHAR(20) UNIQUE NOT NULL,
  `type` ENUM('Two-Wheeler', 'Four-Wheeler', 'Heavy-Vehicle') NOT NULL DEFAULT 'Four-Wheeler',
  `owner_name` VARCHAR(100) DEFAULT NULL,
  `owner_phone` VARCHAR(20) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_license_plate` (`license_plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Parking_Slots Table
CREATE TABLE IF NOT EXISTS `Parking_Slots` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `area_id` INT NOT NULL,
  `slot_number` VARCHAR(20) NOT NULL,
  `type` ENUM('Two-Wheeler', 'Four-Wheeler', 'Heavy-Vehicle') NOT NULL DEFAULT 'Four-Wheeler',
  `status` ENUM('Available', 'Occupied', 'Maintenance') NOT NULL DEFAULT 'Available',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`area_id`) REFERENCES `Parking_Areas` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_area_slot` (`area_id`, `slot_number`),
  INDEX `idx_area_id` (`area_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Parking_Records Table
CREATE TABLE IF NOT EXISTS `Parking_Records` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `vehicle_id` INT NOT NULL,
  `slot_id` INT NOT NULL,
  `attendant_id` INT NOT NULL, -- References Users.id (who recorded entry/exit)
  `entry_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `exit_time` TIMESTAMP NULL DEFAULT NULL,
  `calculated_fee` DECIMAL(10, 2) DEFAULT 0.00,
  `status` ENUM('Active', 'Completed') NOT NULL DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`vehicle_id`) REFERENCES `Vehicles` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`slot_id`) REFERENCES `Parking_Slots` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`attendant_id`) REFERENCES `Users` (`id`) ON DELETE CASCADE,
  INDEX `idx_vehicle_id` (`vehicle_id`),
  INDEX `idx_slot_id` (`slot_id`),
  INDEX `idx_record_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Payments Table
CREATE TABLE IF NOT EXISTS `Payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `record_id` INT NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `payment_method` ENUM('Cash', 'UPI', 'Card') NOT NULL DEFAULT 'Cash',
  `payment_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `transaction_id` VARCHAR(100) UNIQUE NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`record_id`) REFERENCES `Parking_Records` (`id`) ON DELETE CASCADE,
  INDEX `idx_record_id` (`record_id`),
  INDEX `idx_payment_date` (`payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- SAMPLE DATA SEEDING
-- --------------------------------------------------------

-- Insert Users (admin password: admin123, attendant password: attendant123)
INSERT INTO `Users` (`id`, `username`, `password_hash`, `email`, `role`, `status`) VALUES
(1, 'admin', '$2a$10$7WG9aDiEu90gaEBGLfN6oe8s25ciIs7niiYrOnFwAIfYvnVJSirtS', 'admin@smartparking.com', 'Admin', 'Active'),
(2, 'attendant', '$2a$10$.o5fP7qfZ8dVx4S/6ZcRxOJlUQzO0pHANM5/yGysnFAVfw4/NL7/m', 'attendant@smartparking.com', 'Attendant', 'Active'),
(3, 'ramesh', '$2a$10$.o5fP7qfZ8dVx4S/6ZcRxOJlUQzO0pHANM5/yGysnFAVfw4/NL7/m', 'ramesh@smartparking.com', 'Attendant', 'Active');

-- Insert Parking Attendants profiles
INSERT INTO `Parking_Attendants` (`id`, `user_id`, `name`, `phone`, `address`, `hire_date`) VALUES
(1, 2, 'Rahul Sharma', '+91 9876543210', 'Block-C, Sector 62, Noida, UP', '2026-01-10'),
(2, 3, 'Ramesh Kumar', '+91 8765432109', 'Nai Sarak, Chandni Chowk, Delhi', '2026-02-15');

-- Insert Parking Areas
INSERT INTO `Parking_Areas` (`id`, `name`, `location`, `slot_count`, `base_price`) VALUES
(1, 'Basement A (General)', 'Basement Floor 1, North Block', 10, 20.00),
(2, 'Ground Level B (VIP & EV)', 'Main Entrance Level, South Block', 5, 40.00),
(3, 'Roof Deck C (Two-Wheeler)', 'Level 4 Open Air Deck', 15, 10.00);

-- Insert Parking Slots
-- Basement A (General) - 10 Slots (Four-Wheeler)
INSERT INTO `Parking_Slots` (`area_id`, `slot_number`, `type`, `status`) VALUES
(1, 'A-01', 'Four-Wheeler', 'Occupied'),
(1, 'A-02', 'Four-Wheeler', 'Available'),
(1, 'A-03', 'Four-Wheeler', 'Available'),
(1, 'A-04', 'Four-Wheeler', 'Maintenance'),
(1, 'A-05', 'Four-Wheeler', 'Available'),
(1, 'A-06', 'Four-Wheeler', 'Available'),
(1, 'A-07', 'Four-Wheeler', 'Available'),
(1, 'A-08', 'Four-Wheeler', 'Available'),
(1, 'A-09', 'Four-Wheeler', 'Available'),
(1, 'A-10', 'Four-Wheeler', 'Available');

-- Ground Level B (VIP & EV) - 5 Slots (Four-Wheeler / Heavy)
INSERT INTO `Parking_Slots` (`area_id`, `slot_number`, `type`, `status`) VALUES
(2, 'B-01', 'Four-Wheeler', 'Occupied'),
(2, 'B-02', 'Four-Wheeler', 'Available'),
(2, 'B-03', 'Heavy-Vehicle', 'Available'),
(2, 'B-04', 'Four-Wheeler', 'Available'),
(2, 'B-05', 'Heavy-Vehicle', 'Maintenance');

-- Roof Deck C (Two-Wheeler) - 15 Slots
INSERT INTO `Parking_Slots` (`area_id`, `slot_number`, `type`, `status`) VALUES
(3, 'C-01', 'Two-Wheeler', 'Available'),
(3, 'C-02', 'Two-Wheeler', 'Available'),
(3, 'C-03', 'Two-Wheeler', 'Available'),
(3, 'C-04', 'Two-Wheeler', 'Available'),
(3, 'C-05', 'Two-Wheeler', 'Available'),
(3, 'C-06', 'Two-Wheeler', 'Available'),
(3, 'C-07', 'Two-Wheeler', 'Available'),
(3, 'C-08', 'Two-Wheeler', 'Available'),
(3, 'C-09', 'Two-Wheeler', 'Available'),
(3, 'C-10', 'Two-Wheeler', 'Available'),
(3, 'C-11', 'Two-Wheeler', 'Available'),
(3, 'C-12', 'Two-Wheeler', 'Available'),
(3, 'C-13', 'Two-Wheeler', 'Available'),
(3, 'C-14', 'Two-Wheeler', 'Available'),
(3, 'C-15', 'Two-Wheeler', 'Available');

-- Insert Sample Vehicles
INSERT INTO `Vehicles` (`id`, `license_plate`, `type`, `owner_name`, `owner_phone`) VALUES
(1, 'DL3CAN1234', 'Four-Wheeler', 'Amit Patel', '+91 9999988888'),
(2, 'HR26BR5678', 'Four-Wheeler', 'Sonia Sen', '+91 9898989898'),
(3, 'MH02EE9999', 'Two-Wheeler', 'Rahul Bose', '+91 9797979797'),
(4, 'KA03MM4321', 'Four-Wheeler', 'Vijay K', '+91 9696969696');

-- Insert Parking Records
-- Record 1: Completed, parked for 3 hours. Fee: 20 + 20*2 = 60.
INSERT INTO `Parking_Records` (`id`, `vehicle_id`, `slot_id`, `attendant_id`, `entry_time`, `exit_time`, `calculated_fee`, `status`) VALUES
(1, 1, 2, 2, '2026-05-29 09:00:00', '2026-05-29 12:15:00', 60.00, 'Completed');

-- Record 2: Completed, parked for 40 mins. Fee: 20.
INSERT INTO `Parking_Records` (`id`, `vehicle_id`, `slot_id`, `attendant_id`, `entry_time`, `exit_time`, `calculated_fee`, `status`) VALUES
(2, 3, 11, 3, '2026-05-29 10:30:00', '2026-05-29 11:10:00', 20.00, 'Completed');

-- Record 3: Active parking session (A-01, occupied above)
INSERT INTO `Parking_Records` (`id`, `vehicle_id`, `slot_id`, `attendant_id`, `entry_time`, `exit_time`, `calculated_fee`, `status`) VALUES
(3, 2, 1, 2, '2026-05-29 18:30:00', NULL, 0.00, 'Active');

-- Record 4: Active parking session (B-01, occupied above)
INSERT INTO `Parking_Records` (`id`, `vehicle_id`, `slot_id`, `attendant_id`, `entry_time`, `exit_time`, `calculated_fee`, `status`) VALUES
(4, 4, 11, 2, '2026-05-29 21:00:00', NULL, 0.00, 'Active');

-- Insert Payments
INSERT INTO `Payments` (`record_id`, `amount`, `payment_method`, `payment_date`, `transaction_id`) VALUES
(1, 60.00, 'Cash', '2026-05-29 12:16:00', 'TXN987654321'),
(2, 20.00, 'UPI', '2026-05-29 11:11:00', 'TXN876543210');
