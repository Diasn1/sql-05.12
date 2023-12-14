CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    amount DECIMAL(10, 2) NOT NULL,
    date timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE make_purchase(
    IN p_user_id INTEGER,
    IN p_product_id INTEGER,
    IN p_quantity INTEGER
)
AS $$
DECLARE
    total_amount DECIMAL(10, 2);
BEGIN
    SELECT price * p_quantity INTO total_amount
    FROM products
    WHERE id = p_product_id;

    UPDATE users
    SET balance = balance - total_amount
    WHERE id = p_user_id;

    UPDATE products
    SET quantity = quantity - p_quantity
    WHERE id = p_product_id;

    INSERT INTO transactions (user_id, product_id, amount)
    VALUES (p_user_id, p_product_id, total_amount);
END;
$$ LANGUAGE plpgsql;

CALL make_purchase(1, 2, 3);
