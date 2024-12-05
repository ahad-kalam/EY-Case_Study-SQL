create database shopease;
use shopease;


-- 1. Show the total number of customers who signed up in each month of 2023

SELECT 
    MONTH(signup_date) AS month, COUNT(*) AS total_customers
FROM
    shopease_customers
WHERE
    YEAR(signup_date) = 2023
GROUP BY MONTH(signup_date)
ORDER BY MONTH(signup_date);


-- 2.  List the top 5 products by total sales amount, including the total quantity sold for each.

SELECT 
    shopease_products.product_name,
    ROUND(SUM(shopease_order_items.quantity * shopease_order_items.price),
            2) AS total_sales
FROM
    shopease_products
        JOIN
    shopease_order_items ON shopease_order_items.product_id = shopease_products.product_id
GROUP BY shopease_products.product_name
ORDER BY total_sales DESC
LIMIT 5;


-- 3.  Find the average order value for each customer who has placed more than 5 orders.


SELECT 
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    round(AVG(o.total_amount),2) AS average_order_value
FROM 
    shopease_orders o
JOIN 
    shopease_customers c ON o.customer_id = c.customer_id
GROUP BY 
    o.customer_id, customer_name
HAVING 
    COUNT(o.order_id) > 5
ORDER BY 
    average_order_value DESC;


-- 4. Get the total number of orders placed in each month of 2023, 
--  and calculate the average order value for each month

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    round(AVG(total_amount),2) AS average_order_value
FROM 
    shopease_orders
WHERE 
    YEAR(order_date) = 2023
GROUP BY 
    DATE_FORMAT(order_date, '%Y-%m')
ORDER BY 
    order_month;


-- 5.  Identify the product categories with the highest average 
--   rating, and list the top 3 categories.

SELECT 
    p.category,
    round(AVG(r.rating),2) AS average_rating
FROM 
    shopease_products p
JOIN 
    shopease_reviews r ON p.product_id = r.product_id
GROUP BY 
    p.category
ORDER BY 
    average_rating DESC
LIMIT 3;


-- 6. Calculate the total revenue generated from each product 
--  category, and find the category with the highest revenue

SELECT 
    p.category,
    round(SUM(oi.quantity * oi.price),2) AS total_revenue
FROM 
    shopease_products p
JOIN 
    shopease_order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC
LIMIT 1;


-- 7.  List the customers who have placed more than 10 orders, 
--  along with the total amount spent by each customer

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    round(SUM(o.total_amount),2) AS total_amount_spent
FROM 
    shopease_customers c
JOIN 
    shopease_orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, customer_name
HAVING 
    COUNT(o.order_id) > 10
ORDER BY 
    total_amount_spent DESC;


-- 8.  Find the products that have never been reviewed, and list their details


SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM 
    shopease_products p
LEFT JOIN 
    shopease_reviews r ON p.product_id = r.product_id
WHERE 
    r.product_id IS NULL;


-- 9.  Show the details of the most expensive order placed, 
--  including the customer information

SELECT 
    o.order_id,
    o.order_date,
    round((o.total_amount),2),
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email
FROM 
    shopease_orders o
JOIN 
    shopease_customers c ON o.customer_id = c.customer_id
WHERE 
    o.total_amount = (SELECT MAX(total_amount) FROM shopease_orders)
LIMIT 1;




-- 10. Get the total quantity of each product sold in the last 30 days, 
--  and identify the top 5 products by quantity sold


SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    shopease_products p
JOIN 
    shopease_order_items oi ON p.product_id = oi.product_id
JOIN 
    shopease_orders o ON oi.order_id = o.order_id
WHERE 
    o.order_date >= CURDATE() - INTERVAL 30 DAY
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_quantity_sold DESC
LIMIT 5;
