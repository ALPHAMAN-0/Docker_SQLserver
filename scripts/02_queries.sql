USE section_b;

DECLARE @id INT = 1;

SELECT id, name, description, price, stock, category
FROM products;

SELECT TOP(1) id, name, description, price, stock, category
FROM products
WHERE id = @id;

INSERT INTO products (name, description, price, stock, category)
OUTPUT INSERTED.id
VALUES ('Mouse', 'Wireless', 1500, 30, 'Electronics');

UPDATE products
SET name = 'Laptop Pro', description = '16 inch, 32GB RAM',
    price = 120000, stock = 5, category = 'Electronics'
WHERE id = @id;