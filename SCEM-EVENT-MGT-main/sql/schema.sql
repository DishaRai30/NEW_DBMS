-- Drop database if it exists
DROP DATABASE IF EXISTS SCEM_EVENT;

-- Create database
CREATE DATABASE SCEM_EVENT;
USE SCEM_EVENT;

-- Create user table
CREATE TABLE user (
    USN VARCHAR(10) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    type ENUM('organizer', 'student') NOT NULL,
    event_register_count INT DEFAULT 0
);

-- Create event table
CREATE TABLE event (
    eventid INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(255) NOT NULL,
    event_description TEXT NOT NULL,
    event_location VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    event_resource_person VARCHAR(255) NOT NULL,
    event_image VARCHAR(255),
    event_max_entries INT NOT NULL
);

-- Create register table
CREATE TABLE register (
    register_id INT AUTO_INCREMENT PRIMARY KEY,
    USN VARCHAR(10),
    event_id INT,
    FOREIGN KEY (USN) REFERENCES user(USN) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES event(eventid) ON DELETE CASCADE
);

-- Create trigger to enforce event_register_count limit
DELIMITER //
CREATE TRIGGER check_event_register_count
BEFORE INSERT ON register
FOR EACH ROW
BEGIN
    DECLARE user_count INT;
    SELECT event_register_count INTO user_count FROM user WHERE USN = NEW.USN;
    IF user_count >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cannot register for more than 5 events';
    ELSE
        UPDATE user SET event_register_count = event_register_count + 1 WHERE USN = NEW.USN;
    END IF;
END;//
DELIMITER ;
