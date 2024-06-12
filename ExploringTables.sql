USE magist;

/*  1. How many orders are there in the dataset? (The orders table contains a row for each order) */

SELECT
	COUNT(*)
FROM
	orders;
    
-- 99,441 orders 

/* 2. Are orders actually delivered? 
Look at columns in the orders table: one of them is called order_status. Most orders seem to be delivered, but some aren’t. 
Find out how many orders are delivered and how many are canceled, unavailable, or in any other status. */

SELECT
	DISTINCT(order_status)
FROM
	orders;

-- order_status: delivered, unavailable, shipped, canceled, invoiced, processing, approved, created

SELECT
	order_status,
	COUNT(*)
FROM
	orders
GROUP BY order_status;

-- delivered - 96478, unavailable - 609, shipped - 1107, canceled -	625, invoiced -	314, processing - 301, approved	- 2, created - 5

/* 3. Is Magist having user growth? A platform losing users left and right isn’t going to be very useful to us. 
It would be a good idea to check for the number of orders grouped by year and month. */

SELECT
	YEAR(order_purchase_timestamp) AS `Year`,
    MONTH(order_purchase_timestamp) AS `Month`,
    COUNT(*) AS Orders
FROM
	orders
GROUP BY
	`Year`,
    `Month`
ORDER BY
	`Year`,
    `Month`;
    
-- As for 2016 - 2018 data, Magist definitely appears to be growing.

/* 4. How many products are there on the products table? */

SELECT
	COUNT(DISTINCT(product_id)) AS product_count
FROM
	products;
    
-- 32,951 products

/* 5. Which are the categories with the most products? 
Since this is an external database and has been partially anonymized, we do not have the names of the products. 
But we do know which categories products belong to. This is the closest we can get to know what sellers are 
offering in the Magist marketplace. **This are the offered products not the sold products** */

SELECT
	product_category_name,
    COUNT(DISTINCT(product_id)) AS total_per_cat
FROM
	products
GROUP BY 
	product_category_name
ORDER BY
	total_per_cat
    DESC;

-- Top 10 categories per number of products:
-- cama_mesa_banho - 3029, esporte_lazer - 2867, moveis_decoracao -	2657, beleza_saude - 2444, utilidades_domesticas - 2335,
-- automotivo -	1900, informatica_acessorios -	1639, brinquedos -	1411, relogios_presentes -	1329, telefonia	- 1134

SELECT
	COUNT(DISTINCT(product_category_name)) AS total_categories,
    COUNT(DISTINCT(product_id)) AS total_products
FROM
	products;

-- There are 74 categories in total and 32,951 products

-- To get the translation of the categories AND the product sold
SELECT 
	pt.product_category_name_english AS category,
    COUNT(oi.product_id) AS sales_per_cat,
    COUNT(DISTINCT(p.product_id)) AS products_per_cat
FROM products AS p
	LEFT JOIN
		product_category_name_translation AS pt
	ON 
		p.product_category_name = pt.product_category_name
	LEFT JOIN
		order_items AS oi
	ON
		p.product_id = oi.product_id
GROUP BY
	category
ORDER BY 
	products_per_cat
    DESC;

-- TOP 10 categories per sales: bed_bath_table -	11115, health_beauty - 9670, sports_leisure	- 8641, furniture_decor	- 8334, 
-- computers_accessories - 7827, housewares - 6964, watches_gifts	- 5991, telephony -	4545, garden_tools - 4347, auto - 4235

-- Top 10 categories per number of products (in english):
-- bed_bath_table - 3029, sports_leisure - 2867, furniture_decor -	2657, health_beauty - 2444, housewares - 2335,
-- auto - 1900, computers_accessories -	1639, toys - 1411, watches_gifts -	1329, telephony	- 1134

/* 6. How many of those products were present in actual transactions? The products table is a “reference” of all the available products. 
Have all these products been involved in orders? The order_items table has more info. */

SELECT 
	COUNT(DISTINCT(product_id)) AS actual_products
FROM
	order_items;

-- ALL products have been present in transactions

/* 7. What’s the price for the most expensive and cheapest products? */

SELECT
	ROUND(MAX(price), 2) AS most_expensive,
    ROUND(MIN(price), 2) AS cheapest,
    ROUND(AVG(price), 2) AS avg_price
FROM
	order_items;

-- most expensive - 6735, cheapest - 0.85, average price - 120.65

SELECT
	ROUND(MAX(price), 2) AS most_expensive,
    ROUND(MIN(price), 2) AS cheapest,
    ROUND(AVG(price), 2) AS avg_price
FROM
	order_items;

-- To get the names of the categories we need to use subqueries or CTEs
-- Here's with subqueries

SELECT
    (SELECT 
		pt.product_category_name_english
     FROM 
		order_items oi
     JOIN 
		products p 
	ON 
        oi.product_id = p.product_id
	JOIN
		product_category_name_translation pt
	ON
		p.product_category_name = pt.product_category_name
     WHERE 
		oi.price = (SELECT MAX(price) FROM order_items)
		LIMIT 1) AS most_expensive_item,
    (SELECT 
		ROUND(MAX(price), 2) 
	FROM 
		order_items) AS most_expensive_price,
    (SELECT 
		pt.product_category_name_english
     FROM 
		order_items oi
     JOIN 
		products p 
	ON 
		oi.product_id = p.product_id
	JOIN
		product_category_name_translation pt
	ON
		p.product_category_name = pt.product_category_name
     WHERE 
		oi.price = (SELECT MIN(price) FROM order_items)
		LIMIT 1) AS cheapest_item,
    (SELECT 
		ROUND(MIN(price), 2) 
	FROM 
		order_items) AS cheapest_price,
    ROUND(AVG(price), 2) AS avg_price
FROM
    order_items;

-- most expensive - housewares - 6735, cheapest - construction_tools - 0.85, average price - 120.65

-- Now with CTEs
WITH max_item AS (
    SELECT 
        pt.product_category_name_english AS most_expensive_item
    FROM 
        order_items oi
    JOIN 
        products p 
    ON 
        oi.product_id = p.product_id
    JOIN
        product_category_name_translation pt
    ON
        p.product_category_name = pt.product_category_name
    WHERE 
        oi.price = (SELECT MAX(price) FROM order_items)
    LIMIT 1
),
min_item AS (
    SELECT 
        pt.product_category_name_english AS cheapest_item
    FROM 
        order_items oi
    JOIN 
        products p 
    ON 
        oi.product_id = p.product_id
    JOIN
        product_category_name_translation pt
    ON
        p.product_category_name = pt.product_category_name
    WHERE 
        oi.price = (SELECT MIN(price) FROM order_items)
    LIMIT 1
),
price_stats AS (
    SELECT 
        ROUND(MAX(price), 2) AS most_expensive_price,
        ROUND(MIN(price), 2) AS cheapest_price,
        ROUND(AVG(price), 2) AS avg_price
    FROM 
        order_items
)
SELECT
    max_item.most_expensive_item,
    (SELECT most_expensive_price FROM price_stats) AS most_expensive_price,
    min_item.cheapest_item,
    (SELECT cheapest_price FROM price_stats) AS cheapest_price,
    avg_price
FROM
    max_item,
    min_item,
    price_stats;

-- We get the same results so it's ok

/* 8. What are the highest and lowest payment values? Some orders contain multiple products. What’s the highest someone 
has paid for an order? Look at the order_payments table and try to find it out.*/

SELECT
	ROUND(MAX(payment_value), 2) AS highest_payment,
    ROUND(MIN(payment_value), 2) AS lowest_payment,
    ROUND(AVG(payment_value), 2) AS avg_payment
FROM
	order_payments;
