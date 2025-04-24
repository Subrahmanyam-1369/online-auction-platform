-- MySQL Schema for the Online Auction Platform
-- Based on the project description in Final Project Mthree.docx

-- Ensure using the correct database (replace 'your_database_name' if needed)
-- CREATE DATABASE IF NOT EXISTS your_database_name;
-- USE your_database_name;

-- Roles Table: Defines user roles (e.g., Admin, User)
CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the role',
    role_name VARCHAR(50) NOT NULL UNIQUE COMMENT 'Name of the role (e.g., Admin, User)'
) COMMENT 'Stores user roles';

-- Users Table: Stores user account information
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the user',
    role_id INT NOT NULL COMMENT 'Foreign key referencing the Roles table',
    full_name VARCHAR(100) NOT NULL COMMENT 'User''s full name',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'User''s unique email address',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password for security',
    status ENUM('active', 'banned', 'pending_verification') DEFAULT 'pending_verification' COMMENT 'User account status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of user registration',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of last profile update',
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE RESTRICT COMMENT 'Ensure role exists before assigning', -- Use RESTRICT to prevent deleting a role if users have it
    INDEX idx_email (email) -- Index for faster email lookups
) COMMENT 'Stores user account details and credentials';

-- Products Table: Stores details about items listed for auction
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the product',
    seller_id INT NOT NULL COMMENT 'Foreign key referencing the Users table (who listed it)',
    name VARCHAR(255) NOT NULL COMMENT 'Name of the product',
    description TEXT COMMENT 'Detailed description of the product',
    product_type ENUM('UserListed', 'Mortgage') NOT NULL COMMENT 'Type of product (User-sold or Admin-managed mortgage)',
    category VARCHAR(100) COMMENT 'Product category (e.g., Electronics, Real Estate)',
    image_url VARCHAR(512) COMMENT 'URL or path to the product image',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the product was added',
    FOREIGN KEY (seller_id) REFERENCES Users(user_id) ON DELETE CASCADE COMMENT 'If seller is deleted, remove their products',
    INDEX idx_seller_id (seller_id),
    INDEX idx_product_type (product_type)
) COMMENT 'Stores details of items available for auction';

-- Auctions Table: Manages auction sessions for products
CREATE TABLE Auctions (
    auction_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the auction',
    product_id INT NOT NULL COMMENT 'Foreign key referencing the Products table',
    auction_type ENUM('Product', 'Mortgage') NOT NULL COMMENT 'Type of auction',
    start_time DATETIME NOT NULL COMMENT 'Timestamp when the auction begins',
    end_time DATETIME NOT NULL COMMENT 'Timestamp when the auction ends',
    starting_price DECIMAL(12, 2) NOT NULL COMMENT 'The initial price set for the auction',
    current_highest_bid DECIMAL(12, 2) COMMENT 'Current highest bid amount (can be starting price initially)',
    winning_user_id INT NULL COMMENT 'Foreign key referencing Users table (winner), NULL if no winner/ongoing',
    status ENUM('pending', 'active', 'ended', 'cancelled') DEFAULT 'pending' COMMENT 'Auction status',
    created_by INT NOT NULL COMMENT 'Foreign key referencing Users table (Admin/User who created it)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the auction was created',
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE COMMENT 'If product is deleted, cancel the auction',
    FOREIGN KEY (winning_user_id) REFERENCES Users(user_id) ON DELETE SET NULL COMMENT 'If winning user is deleted, keep auction record but remove winner link',
    FOREIGN KEY (created_by) REFERENCES Users(user_id) ON DELETE CASCADE COMMENT 'If creator user is deleted, remove the auction',
    INDEX idx_product_id (product_id),
    INDEX idx_status (status),
    INDEX idx_end_time (end_time),
    INDEX idx_auction_type (auction_type),
    INDEX idx_winning_user_id (winning_user_id),
    INDEX idx_created_by (created_by)
) COMMENT 'Manages auction sessions, timing, pricing, and status';

-- Bids Table: Records bids placed by users on auctions
CREATE TABLE Bids (
    bid_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the bid',
    auction_id INT NOT NULL COMMENT 'Foreign key referencing the Auctions table',
    user_id INT NOT NULL COMMENT 'Foreign key referencing the Users table (who placed the bid)',
    bid_amount DECIMAL(12, 2) NOT NULL COMMENT 'The amount of the bid',
    bid_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the bid was placed',
    FOREIGN KEY (auction_id) REFERENCES Auctions(auction_id) ON DELETE CASCADE COMMENT 'If auction is deleted, remove associated bids',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE COMMENT 'If user is deleted, remove their bids',
    INDEX idx_auction_id (auction_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT chk_bid_amount CHECK (bid_amount > 0) -- Ensure bid amount is positive
) COMMENT 'Records individual bids placed on auctions';

-- Fraud_Reports Table: Logs suspicious activities detected or reported
CREATE TABLE Fraud_Reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the fraud report',
    reported_user_id INT NULL COMMENT 'Foreign key referencing Users (user suspected), NULL if system-generated without specific user',
    reporting_admin_id INT NULL COMMENT 'Foreign key referencing Users (admin who reported), NULL if system-generated',
    reason TEXT NOT NULL COMMENT 'Description of the suspicious activity',
    related_auction_id INT NULL COMMENT 'Foreign key referencing Auctions (if related to an auction)',
    related_bid_id INT NULL COMMENT 'Foreign key referencing Bids (if related to a specific bid)',
    status ENUM('pending_review', 'action_taken', 'dismissed') DEFAULT 'pending_review' COMMENT 'Status of the fraud report',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the report was generated/logged',
    FOREIGN KEY (reported_user_id) REFERENCES Users(user_id) ON DELETE SET NULL COMMENT 'Keep report even if reported user is deleted',
    FOREIGN KEY (reporting_admin_id) REFERENCES Users(user_id) ON DELETE SET NULL COMMENT 'Keep report even if reporting admin is deleted',
    FOREIGN KEY (related_auction_id) REFERENCES Auctions(auction_id) ON DELETE SET NULL COMMENT 'Keep report even if related auction is deleted',
    FOREIGN KEY (related_bid_id) REFERENCES Bids(bid_id) ON DELETE SET NULL COMMENT 'Keep report even if related bid is deleted',
    INDEX idx_reported_user_id (reported_user_id),
    INDEX idx_status_fraud (status)
) COMMENT 'Logs potential fraudulent activities for admin review';

-- Notifications Table: Stores notifications for users
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the notification',
    user_id INT NOT NULL COMMENT 'Foreign key referencing Users table (recipient)',
    message TEXT NOT NULL COMMENT 'The notification text',
    is_read BOOLEAN DEFAULT FALSE COMMENT 'Flag indicating if the user has read the notification',
    related_auction_id INT NULL COMMENT 'Foreign key referencing Auctions (optional link to relevant auction)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of notification creation',
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE COMMENT 'If user is deleted, remove their notifications',
    FOREIGN KEY (related_auction_id) REFERENCES Auctions(auction_id) ON DELETE SET NULL COMMENT 'Keep notification even if related auction is deleted',
    INDEX idx_user_id_notifications (user_id),
    INDEX idx_is_read (is_read)
) COMMENT 'Stores user-specific notifications (e.g., outbid alerts, auction end)';

-- --- End of Schema Script ---
