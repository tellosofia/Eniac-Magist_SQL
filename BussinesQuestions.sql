USE magist; -- otherwise I would have to type it every time, always run it!

SELECT
	products.*,
    product_category_name_translation.product_category_name_english
FROM
	products
LEFT JOIN
	product_category_name_translation
    ON
    products.product_category_name = product_category_name_translation.product_category_name
;

-- Where does MAGIST sale its products?

SELECT
	g.zip_code_prefix,
    g.city,
    g.state,
    c.customer_zip_code_prefix,
    s.seller_zip_code_prefix
FROM
	geo g
LEFT JOIN
	customers c
    ON 
    g.zip_code_prefix = c.customer_zip_code_prefix
LEFT JOIN
	sellers s
    ON
    g.zip_code_prefix = s.seller_zip_code_prefix
;

/* 3.1. In relation to the products:

P1. What categories of tech products does Magist have?*/

SELECT
	product_category_name_english
FROM
	product_category_name_translation
WHERE
	product_category_name_english LIKE '%tech%'
    OR 
    product_category_name_english LIKE '%comp%'
    OR
    product_category_name_english LIKE '%lap%'
    OR 
    product_category_name_english LIKE '%audio%'
    OR 
    product_category_name_english LIKE '%photo%'
    OR 
    product_category_name_english LIKE '%phone%'
    OR 
    product_category_name_english LIKE '%tele%'
    OR 
    product_category_name_english LIKE '%cel%'
    OR 
    product_category_name_english LIKE '%game%'
    OR 
    product_category_name_english LIKE '%tool%'
    OR 
    product_category_name_english LIKE '%elect%'
    OR 
    product_category_name_english LIKE '%acc%'
    OR 
    product_category_name_english LIKE '%app%'
    OR 
    product_category_name_english LIKE '%mob%'
    OR 
    product_category_name_english LIKE '%music%' 
    OR 
    product_category_name_english LIKE '%off%'
    OR 
    product_category_name_english LIKE '%tab%'
;

SELECT
	*
FROM
	product_category_name_translation
WHERE
	product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers')
;

/* P2. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
What percentage does that represent from the overall number of products sold? */

SELECT
	COUNT(product_id)
FROM
	order_items;
    
SELECT
	COUNT(product_id)
FROM
	order_items;
	
SELECT
	pt.product_category_name_english,
    COUNT(oi.product_id) AS '#ofSales',
    ROUND((COUNT(oi.product_id)/112650)*100, 2) AS '%ofTotalSales',
    COUNT(pr.product_id) AS '#ofProducts',
    ROUND((COUNT(pr.product_id)/32951)*100, 2) AS '%ofTotalProducts'
FROM
	product_category_name_translation pt
INNER JOIN
	products pr
    ON
    pt.product_category_name = pr.product_category_name
RIGHT JOIN
	order_items oi
    ON
    pr.product_id = oi.product_id
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	pt.product_category_name_english
;

SELECT
    COUNT(pr.product_id) AS 'TotalofTechProducts',
    COUNT(oi.product_id) AS 'TotalofTechSales'
FROM
	product_category_name_translation pt
INNER JOIN
	products pr
    ON
    pt.product_category_name = pr.product_category_name
RIGHT JOIN
	order_items oi
    ON
    pr.product_id = oi.product_id
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
;

/* P3. What’s the average price of the products being sold?*/

SELECT
	MAX(price) AS MostExpensive,
    MIN(price) AS Cheapest,
    ROUND(AVG(price)) AS AVGPrice
FROM
	order_items
;

SELECT
	pt.product_category_name_english,
	COUNT(oi.product_id) AS '#ofSales',
    ROUND((COUNT(oi.product_id)/112650)*100, 2) AS '%ofTotalSales',
    COUNT(pr.product_id) AS '#ofProducts',
    ROUND((COUNT(pr.product_id)/32951)*100, 2) AS '%ofTotalProducts',
    MAX(oi.price) AS MostExpensive,
    MIN(oi.price) AS Cheapest,
    ROUND(AVG(oi.price)) AS AVGPrice
FROM
	product_category_name_translation pt
INNER JOIN
	products pr
    ON
    pt.product_category_name = pr.product_category_name
INNER JOIN
	order_items oi
    ON
    pr.product_id = oi.product_id
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	pt.product_category_name_english
;

/* P4. Are expensive tech products popular? *
* TIP: Look at the function CASE WHEN to accomplish this task. */

SELECT
	DISTINCT(pr.product_id),
    pt.product_category_name_english,
    COUNT(DISTINCT(pr.product_id)) AS '#ofProducts',
    ROUND((COUNT(pr.product_id)/32951)*100, 2) AS '%ofTotalProducts',
    oi.price AS Price,
CASE
	WHEN oi.price >= 540 THEN 'HighEnd - More than 540€'
    WHEN oi.price >= 200 THEN 'Medium - More than 200€'
    WHEN oi.price >= 80 THEN 'Medium-Low - More than 80€'
    ELSE 'Lower than 80€'
END AS 'PriceCategory'
FROM
	product_category_name_translation pt
INNER JOIN
	products pr
    ON
    pt.product_category_name = pr.product_category_name
INNER JOIN
	order_items oi
    ON
    pr.product_id = oi.product_id
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	pt.product_category_name_english,
    oi.price,
    pr.product_id
ORDER BY
	Price
    DESC
;

SELECT
CASE
	WHEN oi.price >= 540 THEN 'HighEnd - More than 540€'
    WHEN oi.price >= 200 THEN 'Medium - More than 200€'
    WHEN oi.price >= 80 THEN 'Medium-Low - More than 80€'
    ELSE 'Lower than 80€'
END AS 'PriceCategory',
	COUNT(*)
FROM
	product_category_name_translation pt
INNER JOIN
	products pr
    ON
    pt.product_category_name = pr.product_category_name
INNER JOIN
	order_items oi
    ON
    pr.product_id = oi.product_id
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	PriceCategory
ORDER BY
	COUNT(*)
    DESC
;

/* 3.2. In relation to the sellers:

S1. How many months of data are included in the magist database? */

SELECT
    COUNT(DISTINCT(MONTH(order_purchase_timestamp))) AS `Month`,
    YEAR(order_purchase_timestamp)
FROM
	orders
GROUP BY
	YEAR(order_purchase_timestamp)
;

/* S2. How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers? */

SELECT
	COUNT(seller_id) -- 3095 sellers
FROM
	sellers
;

SELECT -- How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
    COUNT(DISTINCT(s.seller_id)) AS '#ofTechSellers',
    ROUND((COUNT(DISTINCT(s.seller_id))/3095)*100, 2) AS '%fromTotalofSellers'
FROM
	sellers s
INNER JOIN
	order_items oi
    ON
    s.seller_id = oi.seller_id
INNER JOIN
	products p
    ON
    oi.product_id = p.product_id
INNER JOIN
	product_category_name_translation pt
    ON
    p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
;

/* S3. What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers? */

SELECT
	ROUND(SUM(price)) AS 'TotalSales'
FROM
	order_items
;

SELECT
	ROUND(SUM(oi.price)) AS 'TotalTechSales',
    ROUND((SUM(oi.price)/13591644)*100, 2) AS '%ofTotalSales'
FROM
	sellers s
INNER JOIN
	order_items oi
    ON
    s.seller_id = oi.seller_id
INNER JOIN
	products p
    ON
    oi.product_id = p.product_id
INNER JOIN
	product_category_name_translation pt
    ON
    p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
;

/* S4. Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?*/

SELECT
	ROUND(AVG(oi.price)) AS 'AVGMonthlyIncome',
    MONTH(o.order_purchase_timestamp) AS 'Month',
    YEAR(o.order_purchase_timestamp) AS 'Year'
FROM
	order_items oi
LEFT JOIN
	orders o
    ON 
    oi.order_id = o.order_id
GROUP BY
	`Year`,
    `Month`
ORDER BY
	`Year`,
    `Month`
;

SELECT
	AVG(oi.price) AS 'AVGMonthlyIncome'
FROM
	sellers s
INNER JOIN
	order_items oi
    ON
    s.seller_id = oi.seller_id
INNER JOIN
	products p
    ON
    oi.product_id = p.product_id
INNER JOIN
	product_category_name_translation pt
    ON
    p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english IN('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
;


/* 3.3. In relation to the delivery time:

DT1. What’s the average time between the order being placed and the product being delivered? */



/* DT2. How many orders are delivered on time vs orders delivered with a delay? */



/* DT3. Is there any pattern for delayed orders, e.g. big products being delayed more often? */
