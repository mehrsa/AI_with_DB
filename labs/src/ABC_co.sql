-- Drop Tables if they exist
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS return_items CASCADE;
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- Create Tables
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2),
    inventory NUMERIC(10, 2),
    refurbished BOOLEAN DEFAULT FALSE,
    category VARCHAR(50) DEFAULT 'Eelectronics'
);
CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    sentiment_score NUMERIC(5, 2) DEFAULT 0,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE sales (
    sales_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    quantity NUMERIC(10, 2),
    product_id INTEGER REFERENCES products(product_id),
    sale_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE return_items (
    return_id SERIAL PRIMARY KEY,
    sales_id INTEGER REFERENCES sales(sales_id),
    return_status VARCHAR(50) NOT NULL,
    reason TEXT,
    status_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    sales_id INTEGER REFERENCES sales(sales_id),
    shipment_date DATE DEFAULT CURRENT_DATE,
    shipment_status VARCHAR(50) NOT NULL,
    latest_status_date DATE
);
CREATE TABLE reviews(
    review_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    product_id INTEGER,
    sales_id  INTEGER REFERENCES sales(sales_id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);


-- Add Data
INSERT INTO products (name, description, price, inventory, refurbished, category) VALUES
('Macbook Pro M4', 'High performance laptop. Ideal for graphic designers and gamers.', 2085, 50, FALSE, 'Laptops'),
('Macbook Pro M3', 'High performance laptop. Ideal for graphic designers and gamers.', 2085, 50, TRUE, 'Laptops'),
('iPhone 14 Pro', 'Latest iPhone with advanced features. Perfect for tech enthusiasts.', 999.99, 20, FALSE, 'Smartphones'),
('iPhone 14 Pro Max', 'Latest iPhone with advanced features. Perfect for tech enthusiasts.', 1099.99, 15, TRUE, 'Smartphones'),
('iPhone 13', 'Great value smartphone with excellent performance.', 799.99, 30, FALSE, 'Smartphones'),
('iPhone 12', 'Affordable smartphone with good performance.', 499.99, 25, TRUE, 'Smartphones'),
('iPhone SE', 'Compact and budget-friendly smartphone.', 399.99, 40, FALSE, 'Smartphones'),
('iPhone 14', 'Why buy new? this phone works great for your daily calling and browsing.', 699.99, 5, TRUE, 'Smartphones'),
('iPhone 16 pro', 'Buy the best and work with the cutting edge!', 2000, 50, FALSE, 'Smartphones'),
('Tablet 0.2', 'Portable tablet with stylus. It is refurbished but in a good condition. Ideal for average daily usage.', 399.99, 10, TRUE, 'Tablets'),
('Tablet 0.2 new', 'Portable tablet with stylus. Brand new. Great option to invest in a durable device.', 650, 40, FALSE, 'Tablets'),
('Jabra Headphone', 'High-quality wireless headphones with noise cancellation.', 199.99, 100, FALSE, 'Headphones'),
('Jabra Headphone Elite', 'Premium wireless headphones with superior sound quality.', 249.99, 50, FALSE, 'Headphones'),
('Jabra Headphone Sport', 'Durable and sweat-resistant headphones for sports enthusiasts.', 149.99, 75, FALSE, 'Headphones'),
('Jabra Headphone Studio', 'Stylish and comfortable headphones for everyday use.', 179.99, 60, FALSE, 'Headphones'),
('Jabra Headphone Pro', 'Professional-grade wireless headphones with superior sound quality. It has the best active noise cancelling in the market.', 299.99, 30, FALSE, 'Headphones'),
('Sony TV 55 inch', '55-inch 4K Ultra HD Smart TV with HDR support.', 799.99, 20, FALSE, 'TVs'),
('Sony TV 65 inch', '65-inch 4K Ultra HD Smart TV with advanced features.', 999.99, 5, TRUE, 'TVs'),
('Sony TV 75 inch', '75-inch 4K Ultra HD Smart TV with immersive viewing experience.', 1599.99, 10, FALSE, 'TVs'),
('Sony TV OLED', '55-inch OLED Smart TV with stunning picture quality.', 1999.99, 20, FALSE, 'TVs')
;

INSERT INTO customers (city, state, country, sentiment_score, name, email) VALUES
('New York', 'NY', 'USA', 4.5, 'John Doe', 'jd@jd.ca'),
('Los Angeles', 'CA', 'USA', 3, 'Jane Smith', 'js@gmail.com'),
('Chicago', 'IL', 'USA', 3.5, 'Alice Johnson', 'aj@yahoo.com'),
('Houston', 'TX', 'USA', 4, 'Bob Brown', 'bb@dl.com'),
('Phoenix', 'AZ', 'USA', 1, 'Charlie White', 'charlie@yahoo.ca'),
('San Francisco', 'CA', 'USA', 0, 'David Green', 'davidg@g.com'),
('Seattle', 'WA', 'USA', 0, 'Eve Black', 'eve@example.ca'),
('New york', 'NY', 'USA', 0, 'Frank Blue', 'fb#test.com'),
('Seattle', 'WA', 'USA', 0,  'Grace Yellow', 'grace@yellow.co'),
('Miami', 'FL', 'USA', 0, 'Hank Purple', 'hp@test.com'),
('Los Angeles', 'CA', 'USA', 0, 'Zara Orange', 'zara@orange.com')
;

INSERT INTO sales (customer_id, quantity, product_id) VALUES
(1, 1, 1),
(2, 2, 2),
(2, 1, 3),
(3, 3, 1),
(5, 2, 2),
(4, 1, 4),
(1, 1, 5),
(2, 1, 6),
(3, 2, 7),
(4, 1, 8),
(5, 1, 9),
(6, 2, 10),
(7, 1, 11),
(8, 3, 12),
(9, 2, 13),
(10, 1, 14),
(1, 2, 15),
(2, 1, 16),
(3, 3, 17),
(4, 2, 18)
;

INSERT INTO return_items (sales_id, return_status, reason, status_date) VALUES
(3, 'Pending', 'Wrong item sent', '2023-10-03'),
(4, 'Completed', 'Item not as described', '2023-10-04'),
(5, 'Pending', 'Item arrived damaged', '2023-10-05'),
(10, 'Completed', 'Changed my mind', '2023-10-06')
;

INSERT INTO reviews (customer_id, product_id, sales_id, rating, review_text) VALUES
(1, 1, 1, 5, 'Excellent laptop!'),
(2, 2, 2, 4, 'Great smartphone but a bit pricey.'),
(2, 1, 3, 2, 'I was sent the wrong item.'),
(3, 1, 4, 2, 'wrong colour!! return was easy'),
(5, 2, 5, 1, 'received a damaged item, disappointed!!!'),
(4, 4, 6, 5, 'Love this phone!'),
(1, 5, 7, 4, 'Great performance and battery life.'),
(2, 6, 8, 3, 'Decent phone but not the best.'),
(3, 7, 9, 5, 'Perfect for my needs!'),
(4, 8, 10, 3, 'Good quality but a bit expensive.')
;

INSERT INTO shipments (sales_id, shipment_date, shipment_status, latest_status_date) VALUES
(1, '2023-10-01', 'Delivered', '2023-10-01'),
(2, '2023-10-02', 'Delivered', '2023-10-02'),
(3, '2023-10-03', 'Delivered', '2023-10-03'),
(4, '2023-10-04', 'Delivered', '2023-10-04'),
(5, '2023-10-05', 'Delivered', '2023-10-05'),
(6, '2023-10-06', 'Delivered', '2023-10-06'),
(7, '2023-10-07', 'Delivered', '2023-10-07'),
(8, '2023-10-08', 'Delivered', '2023-10-08'),
(9, '2023-10-09', 'Delivered', '2023-10-09'),
(10, '2023-10-10', 'Delivered', '2023-10-10'),
(11, '2023-10-11', 'In Transit', '2023-10-11'),
(12, '2023-10-12', 'In Transit', '2023-10-12'),
(13, '2023-10-13', 'In Transit', '2023-10-13'),
(14, '2023-10-14', 'In Transit', '2023-10-14'),
(15, '2023-10-15', 'In Transit', '2023-10-15'),
(16, '2023-10-16', 'In Transit', '2023-10-16'),
(17, '2023-10-17', 'Preparing', '2023-10-17'),
(18, '2023-10-18', 'Preparing', '2023-10-18'),
(19, '2023-10-19', 'Preparing', '2023-10-19'),
(20, '2023-10-20', 'Not Started', '2023-10-20')
;
