-- Database setup script for Interview Experience Sharing Portal
-- Target Database: MySQL 8.x

CREATE DATABASE IF NOT EXISTS interview_portal_db;
USE interview_portal_db;

-- 1. Users Table
DROP TABLE IF EXISTS interview_experiences;
DROP TABLE IF EXISTS analytics_log;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS admin;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Interview Experiences Table
CREATE TABLE interview_experiences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    role VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    rounds_count INT NOT NULL,
    questions_asked TEXT NOT NULL,
    difficulty_level VARCHAR(20) NOT NULL, -- 'Easy', 'Medium', 'Hard'
    result VARCHAR(20) NOT NULL,          -- 'Selected', 'Rejected', 'Waiting'
    tips TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Admin Table
CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Analytics Log Table
CREATE TABLE analytics_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL, -- e.g., 'SEARCH', 'VIEW_ANALYTICS', 'USER_LOGIN'
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert Sample Data
-- Sample Admin User (password: 'admin123' hashed or plain - we will check credentials using equals() or simple hash. Let's use plain text or simple MD5 for demonstration, let's use plain text for robustness in learning code, or check plain text with standard comparison)
INSERT INTO admin (username, password, email) VALUES 
('admin', 'admin123', 'admin@interviewportal.com');

-- Sample Users (passwords: 'user123', 'alice123', 'bob123')
INSERT INTO users (username, password, email, full_name) VALUES 
('john_doe', 'user123', 'john@gmail.com', 'John Doe'),
('alice_smith', 'alice123', 'alice@gmail.com', 'Alice Smith'),
('bob_jones', 'bob123', 'bob@gmail.com', 'Bob Jones');

-- Sample Interview Experiences
INSERT INTO interview_experiences (user_id, company_name, role, interview_date, rounds_count, questions_asked, difficulty_level, result, tips) VALUES 
(1, 'Google', 'Software Engineer', '2026-05-10', 4, '1. Binary Tree Maximum Path Sum.\n2. Design a rate limiter.\n3. Implement a thread-safe LRU cache.', 'Hard', 'Selected', 'Focus heavily on dynamic programming, graphs, and system design. Keep talking through your thought process.'),
(1, 'Microsoft', 'Software Engineer II', '2026-04-15', 3, '1. Reverse a linked list in groups of k.\n2. Design patterns (Singleton, Factory).\n3. Find LCA of binary tree.', 'Medium', 'Selected', 'Be clear on design patterns. Practice writing clean, bug-free code on paper/whiteboard.'),
(2, 'Amazon', 'SDE 1', '2026-06-01', 4, '1. Merge k sorted lists.\n2. Top K frequent elements.\n3. Leadership Principles questions (tell me about a time you failed).', 'Hard', 'Rejected', 'Leadership principles are as important as coding. Quantify your answers using the STAR method.'),
(3, 'Meta', 'Software Engineer', '2026-05-20', 3, '1. Subarray sum equals k.\n2. Find all anagrams in a string.\n3. Standard behavioral questions.', 'Medium', 'Waiting', 'Meta coding rounds require optimal solutions quickly. Focus on speed and space complexity.'),
(2, 'Netflix', 'Senior Engineer', '2026-03-12', 5, '1. High volume stream ingestion architectures.\n2. Key-value store design.\n3. Chaos engineering principles.', 'Hard', 'Selected', 'Be very opinionated about architecture. Netflix values freedom and responsibility, know their culture document.'),
(3, 'Google', 'Associate Product Manager', '2026-06-05', 3, '1. How would you design a product to search for physical objects?\n2. Estimate the number of cell towers in Chicago.', 'Medium', 'Selected', 'Structure your answers using circles method. Practice Fermi estimations.');

-- Sample Analytics Logs
INSERT INTO analytics_log (event_type, description) VALUES
('SYSTEM_INIT', 'Database schema created and seed data inserted.'),
('SEARCH', 'User john_doe searched for company: Google'),
('SEARCH', 'User alice_smith searched for role: SDE'),
('VIEW_ANALYTICS', 'User john_doe viewed the dashboard analytics.');
