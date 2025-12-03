-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 18, 2025 at 04:40 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `project`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_info`
--

CREATE TABLE `admin_info` (
  `admin_id` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_info`
--

INSERT INTO `admin_info` (`admin_id`, `password`) VALUES
('Admin01', 'Admin01');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `owner_name` varchar(255) NOT NULL,
  `pet_name` varchar(255) NOT NULL,
  `pet_age` int(11) NOT NULL,
  `pet_breed` varchar(255) NOT NULL,
  `service_type` varchar(50) NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `booking_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','in_progress','completed','cancelled') DEFAULT 'pending',
  `review` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `special_instructions` varchar(500) DEFAULT NULL,
  `amount_payable` int(11) DEFAULT NULL,
  `user_email` varchar(50) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `employee_id`, `owner_name`, `pet_name`, `pet_age`, `pet_breed`, `service_type`, `time_slot`, `address`, `phone_number`, `booking_date`, `created_at`, `status`, `review`, `updated_at`, `special_instructions`, `amount_payable`, `user_email`, `rating`) VALUES
(1, 8, 'xyz sharma', 'koya', 4, 'mixed breed', 'Daycare', 'evening', 'A03,vrindavan heights,near lakshmi road', '1111111111', '2025-10-12', '2025-10-12 13:24:20', 'completed', 'very nice service, the caretaker was very friendly and kind', '2025-10-12 13:26:47', 'My dog is very friendly,please be on time as i have a meeting this noon', 500, 'xyz@gmail.com', 4),
(2, 3, 'xyz sharma', 'koya', 4, 'mixed breed', 'Walker', 'morning', 'A03,vrindavan heights,near lakshmi road', '1111111111', '2025-10-12', '2025-10-12 13:28:32', 'cancelled', NULL, '2025-10-12 13:29:16', '', 250, 'xyz@gmail.com', NULL),
(3, 2, 'efg solanki', 'tiya', 6, 'golden retriever', 'Vet', 'afternoon', '35,Nehru bunglows, near shanti primary school', '2222222222', '2025-10-12', '2025-10-12 13:33:54', 'completed', '', '2025-10-12 13:35:56', 'please bring cleaned equipments', 1200, 'efg@gmail.com', 2),
(4, 1, 'abc agrawal', 'suzy', 3, 'labrador', 'Groomer', 'morning', '05,ashirwad society ,near mansarovar road', '3333333333', '2025-10-12', '2025-10-12 13:40:49', 'completed', 'very good service', '2025-10-12 13:44:38', 'my dog has allergies from scented product, please bring scented free products', 800, 'abc@gmail.com', 4),
(5, 5, 'abc agrawal', 'suzy', 4, 'german shepherd', 'Vet', 'morning', '35,Nehru bunglows, near shanti primary school', '3333333333', '2025-10-12', '2025-10-12 15:02:19', 'completed', 'great service', '2025-10-12 15:03:09', '', 1200, 'abc@gmail.com', 4),
(6, 2, 'xyz sharma', 'koya', 8, 'golden retriever', 'Vet', 'afternoon', '05,ashirwad society ,near mansarovar road', '2222222222', '2025-10-13', '2025-10-13 06:18:37', 'completed', '', '2025-10-13 06:20:53', '', 1200, 'abc@gmail.com', 3);

-- --------------------------------------------------------

--
-- Table structure for table `cancelled_appointments`
--

CREATE TABLE `cancelled_appointments` (
  `cancel_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `owner_name` varchar(255) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `service_type` varchar(100) NOT NULL,
  `booking_date` date NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `amount_payable` int(11) NOT NULL,
  `cancel_reason` varchar(500) DEFAULT NULL,
  `cancelled_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancelled_by` enum('user','admin','employee') DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cancelled_appointments`
--

INSERT INTO `cancelled_appointments` (`cancel_id`, `booking_id`, `user_email`, `employee_id`, `owner_name`, `pet_name`, `service_type`, `booking_date`, `time_slot`, `amount_payable`, `cancel_reason`, `cancelled_at`, `cancelled_by`) VALUES
(1, 2, 'xyz@gmail.com', 3, 'xyz sharma', 'koya', 'Walker', '2025-10-12', 'morning', 250, 'i booked it out of curiosity', '2025-10-12 13:29:16', 'user');

-- --------------------------------------------------------

--
-- Table structure for table `completed_appointments`
--

CREATE TABLE `completed_appointments` (
  `complete_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `owner_name` varchar(255) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `service_type` varchar(100) NOT NULL,
  `booking_date` date NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `amount_payable` int(11) NOT NULL,
  `special_instructions` varchar(500) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `pet_breed` varchar(100) DEFAULT NULL,
  `pet_age` int(11) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_by` enum('employee') DEFAULT 'employee'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `completed_appointments`
--

INSERT INTO `completed_appointments` (`complete_id`, `booking_id`, `user_email`, `employee_id`, `owner_name`, `pet_name`, `service_type`, `booking_date`, `time_slot`, `amount_payable`, `special_instructions`, `rating`, `review`, `pet_breed`, `pet_age`, `phone_number`, `address`, `completed_at`, `completed_by`) VALUES
(1, 1, 'xyz@gmail.com', 8, 'xyz sharma', 'koya', 'Daycare', '2025-10-12', 'evening', 500, 'My dog is very friendly,please be on time as i have a meeting this noon', 4, 'very nice service, the caretaker was very friendly and kind', 'mixed breed', 4, '1111111111', 'A03,vrindavan heights,near lakshmi road', '2025-10-12 13:25:31', 'employee'),
(2, 3, 'efg@gmail.com', 2, 'efg solanki', 'tiya', 'Vet', '2025-10-12', 'afternoon', 1200, 'please bring cleaned equipments', 2, '', 'golden retriever', 6, '2222222222', '35,Nehru bunglows, near shanti primary school', '2025-10-12 13:35:46', 'employee'),
(3, 4, 'abc@gmail.com', 1, 'abc agrawal', 'suzy', 'Groomer', '2025-10-12', 'morning', 800, 'my dog has allergies from scented product, please bring scented free products', 4, 'very good service', 'labrador', 3, '3333333333', '05,ashirwad society ,near mansarovar road', '2025-10-12 13:43:25', 'employee'),
(4, 5, 'abc@gmail.com', 5, 'abc agrawal', 'suzy', 'Vet', '2025-10-12', 'morning', 1200, '', 4, 'great service', 'german shepherd', 4, '3333333333', '35,Nehru bunglows, near shanti primary school', '2025-10-12 15:02:39', 'employee'),
(5, 6, 'abc@gmail.com', 2, 'xyz sharma', 'koya', 'Vet', '2025-10-13', 'afternoon', 1200, '', 3, '', 'golden retriever', 8, '2222222222', '05,ashirwad society ,near mansarovar road', '2025-10-13 06:19:59', 'employee');

-- --------------------------------------------------------

--
-- Table structure for table `employee_info`
--

CREATE TABLE `employee_info` (
  `employee_id` int(11) NOT NULL,
  `full_name` varchar(50) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `emp_email` varchar(100) NOT NULL,
  `role` enum('groomer','walker','vet assistant','care taker') DEFAULT NULL,
  `hire_date` date NOT NULL,
  `age` int(11) NOT NULL,
  `employment_status` enum('Active','Inactive') NOT NULL,
  `rating` int(11) NOT NULL,
  `experience` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_info`
--

INSERT INTO `employee_info` (`employee_id`, `full_name`, `phone`, `emp_email`, `role`, `hire_date`, `age`, `employment_status`, `rating`, `experience`) VALUES
(1, 'Amit Sharma', '9765432109', 'amit@gmail.com', 'groomer', '2025-08-26', 21, 'Active', 4, '0-1'),
(2, 'Neha Verma', '9823456789', 'neha.verma@gmail.com', 'vet assistant', '2025-08-25', 29, 'Active', 5, '3-5'),
(3, 'Rohit Mehta', '9891122334', 'rohit.mehta@gmail.com', 'walker', '2025-08-24', 24, 'Active', 3, '1-3'),
(4, 'Priya Nair', '9812233445', 'priya.nair@gmail.com', 'care taker', '2025-08-23', 32, 'Active', 4, '5+'),
(5, 'Sanjay Patel', '9809988776', 'sanjay.patel@gmail.com', 'vet assistant', '2025-08-22', 41, 'Active', 5, '5+'),
(6, 'Ankita Joshi', '9876677889', 'ankita.joshi@gmail.com', 'groomer', '2025-08-21', 27, 'Inactive', 4, '1-3'),
(7, 'Karan Singh', '9798877665', 'karan.singh@gmail.com', 'walker', '2025-08-20', 22, 'Inactive', 3, '0-1'),
(8, 'Meera Desai', '9787766554', 'meera.desai@gmail.com', 'care taker', '2025-08-19', 36, 'Active', 5, '3-5'),
(9, 'Vikram Gupta', '9776655443', 'vikram.gupta@gmail.com', 'care taker', '2025-08-18', 45, 'Inactive', 4, '5+'),
(10, 'Shalini Rao', '9765544332', 'shalini.rao@gmail.com', 'groomer', '2025-08-17', 31, 'Active', 5, '3-5'),
(22, 'abc', '4444444444', 'abc@gmail.com', 'walker', '2025-10-13', 18, 'Active', 0, '1-3');

-- --------------------------------------------------------

--
-- Table structure for table `search_bookings`
--

CREATE TABLE `search_bookings` (
  `id` int(11) NOT NULL,
  `service_type` varchar(50) NOT NULL,
  `pet_type` varchar(50) NOT NULL,
  `address` varchar(255) NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `booking_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `search_bookings`
--

INSERT INTO `search_bookings` (`id`, `service_type`, `pet_type`, `address`, `time_slot`, `phone_number`, `booking_date`) VALUES
(1, 'Groomer', 'dog', 'abc lane', 'morning', '4444444444', '2025-10-12'),
(2, 'Daycare', 'dog', 'A03,vrindavan heights,near lakshmi road', 'evening', '1111111111', '2025-10-12'),
(3, 'Walker', 'dog', 'A03,vrindavan heights,near lakshmi road', 'morning', '1111111111', '2025-10-12'),
(4, 'Vet', 'dog', '35,Nehru bunglows, near shanti primary school', 'afternoon', '2222222222', '2025-10-12'),
(5, 'Groomer', 'dog', '05,ashirwad society ,near mansarovar road ', 'morning', '3333333333', '2025-10-12'),
(6, 'Vet', 'dog', 'A03,vrindavan heights,near lakshmi road', 'afternoon', '3333333333', '2025-10-12'),
(7, 'Vet', 'dog', '35,Nehru bunglows, near shanti primary school', 'morning', '3333333333', '2025-10-12'),
(8, 'Vet', 'dog', '35,Nehru bunglows, near shanti primary school', 'afternoon', '1111111111', '2025-10-12'),
(9, 'Daycare', 'dog', 'A03,vrindavan heights,near lakshmi road', 'evening', '9891122334', '2025-10-13'),
(10, 'Daycare', 'dog', 'A03,vrindavan heights,near lakshmi road', 'evening', '9891122334', '2025-10-13'),
(11, 'Daycare', 'dog', 'A03,vrindavan heights,near lakshmi road', 'evening', '9891122334', '2025-10-13'),
(12, 'Vet', 'dog', '05,ashirwad society ,near mansarovar road ', 'afternoon', '2222222222', '2025-10-13');

-- --------------------------------------------------------

--
-- Table structure for table `sitter_applications`
--

CREATE TABLE `sitter_applications` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `service_type` enum('groomer','walker','care taker','vet assistant') DEFAULT NULL,
  `experience` enum('0-1','1-3','3-5','5+') NOT NULL,
  `age` int(2) NOT NULL,
  `message` text NOT NULL,
  `status` varchar(20) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sitter_applications`
--

INSERT INTO `sitter_applications` (`id`, `full_name`, `email`, `phone`, `service_type`, `experience`, `age`, `message`, `status`) VALUES
(1, 'Kavita Narsighgani', 'kavita2020@gmail.com', '1234567899', 'walker', '5+', 30, 'I have a work experience of 5+ years and have a friendly nature with dogs', 'accepted'),
(2, 'somil Singh', 'soumil99@gmail.com', '9876543211', 'walker', '3-5', 19, 'I\'m a college fresher and want a side source of income', 'rejected'),
(3, 'Riya Gupta', 'riyag@gmail.com', '5555555555', 'care taker', '1-3', 21, 'I have certain certificates and want a job immediately as i don\'t have any', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `user_info`
--

CREATE TABLE `user_info` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_info`
--

INSERT INTO `user_info` (`user_id`, `user_email`, `user_password`) VALUES
(1, 'abc@gmail.com', 'temp123'),
(2, 'efg@gmail.com', 'temp123'),
(3, 'xyz@gmail.com', 'temp123'),
(4, 'kavyaagrawal020@gmail.com', 'tNvyXw1h');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_info`
--
ALTER TABLE `admin_info`
  ADD PRIMARY KEY (`admin_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `idx_bookings_status` (`status`),
  ADD KEY `idx_bookings_employee_date` (`employee_id`,`booking_date`),
  ADD KEY `idx_employee_booking_date` (`employee_id`,`booking_date`,`status`),
  ADD KEY `idx_user_bookings` (`user_email`,`status`),
  ADD KEY `idx_pending_bookings` (`status`,`booking_date`);

--
-- Indexes for table `cancelled_appointments`
--
ALTER TABLE `cancelled_appointments`
  ADD PRIMARY KEY (`cancel_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `idx_user_email` (`user_email`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_cancelled_at` (`cancelled_at`);

--
-- Indexes for table `completed_appointments`
--
ALTER TABLE `completed_appointments`
  ADD PRIMARY KEY (`complete_id`),
  ADD KEY `idx_booking_id` (`booking_id`),
  ADD KEY `idx_user_email` (`user_email`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_completed_at` (`completed_at`);

--
-- Indexes for table `employee_info`
--
ALTER TABLE `employee_info`
  ADD PRIMARY KEY (`employee_id`);

--
-- Indexes for table `search_bookings`
--
ALTER TABLE `search_bookings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sitter_applications`
--
ALTER TABLE `sitter_applications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_info`
--
ALTER TABLE `user_info`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `cancelled_appointments`
--
ALTER TABLE `cancelled_appointments`
  MODIFY `cancel_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `completed_appointments`
--
ALTER TABLE `completed_appointments`
  MODIFY `complete_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `employee_info`
--
ALTER TABLE `employee_info`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `search_bookings`
--
ALTER TABLE `search_bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `sitter_applications`
--
ALTER TABLE `sitter_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_info`
--
ALTER TABLE `user_info`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
