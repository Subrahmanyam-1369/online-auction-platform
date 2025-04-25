CREATE DATABASE IF NOT EXISTS onlineauction;
USE onlineauction;

CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status ENUM('active', 'banned', 'pending_verification') DEFAULT 'pending_verification',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE RESTRICT,
    INDEX idx_email (email)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    product_type ENUM('UserListed', 'Mortgage') NOT NULL,
    category VARCHAR(100),
    image_url VARCHAR(512),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_seller_id (seller_id),
    INDEX idx_product_type (product_type)
);

CREATE TABLE Auctions (
    auction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    auction_type ENUM('Product', 'Mortgage') NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    starting_price DECIMAL(12, 2) NOT NULL,
    current_highest_bid DECIMAL(12, 2),
    winning_user_id INT NULL,
    status ENUM('pending', 'active', 'ended', 'cancelled') DEFAULT 'pending',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (winning_user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_status (status),
    INDEX idx_end_time (end_time),
    INDEX idx_auction_type (auction_type),
    INDEX idx_winning_user_id (winning_user_id),
    INDEX idx_created_by (created_by)
);

CREATE TABLE Bids (
    bid_id INT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    user_id INT NOT NULL,
    bid_amount DECIMAL(12, 2) NOT NULL,
    bid_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES Auctions(auction_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_auction_id (auction_id),
    INDEX idx_user_id (user_id),
    CONSTRAINT chk_bid_amount CHECK (bid_amount > 0)
);

CREATE TABLE Fraud_Reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    reported_user_id INT NULL,
    reporting_admin_id INT NULL,
    reason TEXT NOT NULL,
    related_auction_id INT NULL,
    related_bid_id INT NULL,
    status ENUM('pending_review', 'action_taken', 'dismissed') DEFAULT 'pending_review',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reported_user_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (reporting_admin_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (related_auction_id) REFERENCES Auctions(auction_id) ON DELETE SET NULL,
    FOREIGN KEY (related_bid_id) REFERENCES Bids(bid_id) ON DELETE SET NULL,
    INDEX idx_reported_user_id (reported_user_id),
    INDEX idx_status_fraud (status)
);

CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_auction_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_auction_id) REFERENCES Auctions(auction_id) ON DELETE SET NULL,
    INDEX idx_user_id_notifications (user_id),
    INDEX idx_is_read (is_read)
);