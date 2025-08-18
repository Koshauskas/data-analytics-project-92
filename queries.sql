--question 4
SELECT COUNT(customer_id) AS customers_count
--calculate all customers by customer_id which is unique
FROM customers;

--question 5
--query1
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
--this query calculates revenue by sellers, sorts it from highest to lowest
--and filters the top 10 sellers
FROM sales AS s
LEFT JOIN employees AS e
    ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

--query2
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    FLOOR(AVG(sl.quantity * pr.price)) AS average_income
--this query finds sellers whose average revenue is less than the average 
--revenue of all sellers and sorts by revenue from lowest to highest
FROM sales AS sl
INNER JOIN employees AS e
    ON sl.sales_person_id = e.employee_id
INNER JOIN products AS pr
    ON sl.product_id = pr.product_id
GROUP BY seller
HAVING
    avg(s.lquantity * pr.price) < (
        SELECT AVG(s.quantity * p.price)
        FROM sales AS s
        INNER JOIN products AS p
            ON s.product_id = p.product_id
    )
ORDER BY average_income ASC;

--query3
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'day'))) AS day_of_week,
    FLOOR(SUM(s.quantity * p.price)) AS income
--this query finds revenue sorted by day of week and sellers
FROM sales AS s
INNER JOIN employees AS e
    ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY
    seller, day_of_week,
    CASE
        WHEN EXTRACT(dow FROM s.sale_date) = 0 THEN 7
        ELSE EXTRACT(dow FROM s.sale_date)
    END
ORDER BY
    CASE
        WHEN EXTRACT(dow FROM s.sale_date) = 0 THEN 7
        ELSE EXTRACT(dow FROM s.sale_date)
    END,
    seller;

--question 6
--query1
--this query counts the number of customers by age category
SELECT
    '16-25' AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
WHERE age >= 16 AND age <= 25
UNION ALL
SELECT
    '26-40' AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
WHERE age >= 26 AND age <= 40
UNION ALL
SELECT
    '40+' AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
WHERE age > 40;

--query2
--this query counts the number of customers and total income by months
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;

--query3
WITH first_sales AS (
    SELECT
        --this query numbers the rows within each customer_id using row_number()
        --number 1 will be the first sale purchase for each customer
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        p.price,
        ROW_NUMBER()
        OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date ASC, s.sales_id ASC
        )
            AS rn
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    WHERE p.price = 0
)

SELECT
    f.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    e.first_name || ' ' || e.last_name AS seller
FROM first_sales AS f
INNER JOIN customers AS c
    ON f.customer_id = c.customer_id
INNER JOIN employees AS e
    ON f.sales_person_id = e.employee_id
WHERE f.rn = 1
ORDER BY c.customer_id ASC
