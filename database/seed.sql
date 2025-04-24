INSERT INTO users (username, email, password) VALUES
('john_doe', 'john@example.com', 'hashed_password_1'),
('jane_smith', 'jane@example.com', 'hashed_password_2');

INSERT INTO products (name, description, starting_price, seller_id, category_id) VALUES
('Antique Vase', 'A beautiful antique vase from the 19th century.', 100.00, 1, 1),
('Vintage Watch', 'A classic vintage watch in excellent condition.', 250.00, 2, 2);

INSERT INTO auctions (product_id, start_time, end_time, current_price, status) VALUES
(1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 100.00, 'active'),
(2, NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), 250.00, 'active');

INSERT INTO bids (user_id, auction_id, bid_amount, bid_time) VALUES
(1, 1, 120.00, NOW()),
(2, 1, 130.00, NOW()),
(1, 2, 260.00, NOW());

INSERT INTO categories (name) VALUES
('Antiques'),
('Watches');