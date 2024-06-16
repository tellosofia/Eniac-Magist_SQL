USE magist;

-- In relation to the PRODUCTS:
/* 1. What categories of tech products does Magist have? */ 

SELECT
	DISTINCT(product_category_name_english) AS categories
FROM
	product_category_name_translation
ORDER BY
	categories;

-- All categories: agro_industry_and_commerce, air_conditioning, art, arts_and_craftmanship, audio, auto, 
-- baby, bed_bath_table, books_general_interest, books_imported, books_technical,
-- cds_dvds_musicals, christmas_supplies, cine_photo, computers, computers_accessories, consoles_games, construction_tools_construction, 
-- construction_tools_lights, construction_tools_safety, cool_stuff, costruction_tools_garden, costruction_tools_tools,
-- diapers_and_hygiene, drinks, dvds_blu_ray, 
-- electronics,
-- fashio_female_clothing, fashion_bags_accessories, fashion_childrens_clothes, fashion_male_clothing, fashion_shoes, fashion_sport, 
-- fashion_underwear_beach, fixed_telephony, flowers, food, food_drink, furniture_bedroom, furniture_decor, furniture_living_room
-- furniture_mattress_and_upholstery,
-- garden_tools,
-- health_beauty, home_appliances, home_appliances_2, home_comfort_2, home_confort, home_construction, housewares,
-- industry_commerce_and_business,
-- kitchen_dining_laundry_garden_furniture, 
-- la_cuisine, luggage_accessories,
-- market_place, music, musical_instruments,
-- office_furniture, others,
-- party_supplies, pc_gamer, perfumery, pet_shop, portable_kitchen_food_processors,
-- security_and_services, signaling_and_security, small_appliances, small_appliances_home_oven_and_coffee, sports_leisure, stationery,
-- tablets_printing_image, telephony, toys, watches_gifts

-- From this 74 categories, we think that the ones that belong to tech are this 11:
-- audio, computers, computers_accessories, consoles_games, electronics, fixed_telephony, music, pc_gamer, tablets_printing_image, 
-- telephony, watches_gifts

/* 2. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
What percentage does that represent from the overall number of products sold? */

-- First we need to know the number of products sold
SELECT 
	COUNT(product_id) AS total_sold_products
FROM
	order_items; -- 112,650 sold products (within the time window of the database snapshot)

-- Now for tech categories
SELECT 
	COUNT(oi.product_id) AS total_sold_products,
    ROUND(COUNT(oi.product_id)/112650 * 100, 2) AS '%_from_total_sales'
FROM
	order_items oi
LEFT JOIN 
	products p
ON 
	oi.product_id = p.product_id
LEFT JOIN 
	product_category_name_translation pt
ON
	p.product_category_name = pt.product_category_name
WHERE 
	pt.product_category_name_english 
    IN
    ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'fixed_telephony', 'music', 'pc_gamer', 
    'tablets_printing_image', 'telephony', 'watches_gifts');

-- Tech categories represent 20.62% of the sales with 23,228 sold products (out of 113k)

/* 3. What’s the average price of the products being sold? */

SELECT
	MAX(price) AS most_expensive,
    MIN(price) AS cheapest,
    ROUND(AVG(price), 2) AS avg_price
FROM
	order_items; -- avg price is 120.65€ for all products, max is 6,735€ and min 0.85€

-- For tech products

SELECT
	MAX(price) AS most_expensive,
    MIN(price) AS cheapest,
    ROUND(AVG(price), 2) AS avg_price
FROM
	order_items oi 
LEFT JOIN 
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
    IN
    ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'fixed_telephony', 'music', 'pc_gamer', 
    'tablets_printing_image', 'telephony', 'watches_gifts'); -- for tech products, the avg. price is 133.75€, with a max of 6,729€,
    -- and a min of 3.85

-- Per category:
SELECT
	product_category_name_english AS category,
	MAX(price) AS most_expensive,
    MIN(price) AS cheapest,
    ROUND(AVG(price), 2) AS avg_price
FROM
	order_items oi 
LEFT JOIN 
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
    IN
    ('audio', 'computers', 'computers_accessories', 'consoles_games', 'electronics', 'fixed_telephony', 'music', 'pc_gamer', 
    'tablets_printing_image', 'telephony', 'watches_gifts')
GROUP BY
	category
ORDER BY
	avg_price DESC; 
    
-- The tech categories with higher avg_price are: computers - 1,098.34€, fixed_telephony - 225.69€, watches_gifts - 201.14€

/* 4. Are expensive tech products popular? */

SELECT
	DISTINCT(p.product_id),
    pt.product_category_name_english,
    COUNT(p.product_id) AS 'sold_products',
    ROUND((COUNT(p.product_id)/32951)*100, 2) AS '%_from_total',
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
	products p
    ON
    pt.product_category_name = p.product_category_name
INNER JOIN
	order_items oi
    ON
    p.product_id = oi.product_id
WHERE
	pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 
    'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	pt.product_category_name_english,
    oi.price,
    p.product_id
ORDER BY
	Price DESC; -- info per product (although we just have the product_id)
    
SELECT
CASE
	WHEN oi.price >= 540 THEN 'HighEnd - More than 540€'
    WHEN oi.price >= 200 THEN 'Medium - More than 200€'
    WHEN oi.price >= 80 THEN 'Medium-Low - More than 80€'
    ELSE 'Lower than 80€'
END AS 'price_category',
	COUNT(*) AS total_per_cat,
    ROUND(COUNT(*)/23228*100, 2) AS '%_from_total_tech'-- this is the total of tech products sold
FROM
	product_category_name_translation pt
INNER JOIN
	products p
    ON
    pt.product_category_name = p.product_category_name
INNER JOIN
	order_items oi
    ON
    p.product_id = oi.product_id
WHERE
	pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	price_category
ORDER BY
	COUNT(*)
    DESC;

-- Cheaper products, from the tech categories, appear to be more popular. Only around 15% of the sold items cost over 200€, and 55% cost less than 80€

-- In relation to the SELLERS:
/* 5. How many months of data are included in the magist database? */ 

SELECT
	COUNT(DISTINCT(DATE_FORMAT(order_purchase_timestamp, '%Y-%m'))) AS 'year_month'
FROM
	orders; -- There are 25 months of data included on the database

SELECT
    COUNT(DISTINCT(MONTH(order_purchase_timestamp))) AS `Month`,
    YEAR(order_purchase_timestamp)
FROM
	orders
GROUP BY
	YEAR(order_purchase_timestamp); -- 3 months from 2016, the whole 2017 and 10 months from 2018

/* 6. How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers? */

SELECT
	COUNT(DISTINCT(seller_id)) AS number_of_sellers
FROM
	sellers; -- There are 3,095 sellers in total

SELECT
    COUNT(DISTINCT(s.seller_id)) AS tech_sellers,
    ROUND(COUNT(DISTINCT(s.seller_id)) / 3095 * 100, 2) AS '%_of_tech_sellers'
FROM
	sellers s
LEFT JOIN
	order_items oi
ON
	s.seller_id = oi.seller_id
LEFT JOIN 
	products p
ON 
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts'); -- There are 560 tech sellers, 18% of the total

/* 7. What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers? */

SELECT
	ROUND(SUM(price), 2) AS total_sales,
    ROUND(SUM(payment_value), 2) AS total_paid
FROM
	order_items oi
LEFT JOIN
	order_payments op
ON
	oi.order_id = op.order_id;
-- Total from order_items: 14,209,250.31€ 
-- Total from payment_value: 20,308,134.86€ -- it also takes into account the cost of freight, etc.

SELECT -- now for tech sellers
	ROUND(SUM(price), 2) AS total_sales,
    ROUND(SUM(payment_value), 2) AS total_paid
FROM
	order_items oi
LEFT JOIN
	order_payments op
ON
	oi.order_id = op.order_id
LEFT JOIN 
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON
	p.product_category_name = pt.product_category_name_english
WHERE
	pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts'); 
-- Tech sales from order_items: 220,240.94€
-- Tech sales from payment_value: 257979.43€ -- it also takes into account the cost of freight, etc.

-- Using UNION ALL
SELECT
    'overall' AS category,
    ROUND(SUM(oi.price), 2) AS total_sales,
    ROUND(SUM(op.payment_value), 2) AS total_paid
FROM
    order_items oi
LEFT JOIN
    order_payments op
ON
    oi.order_id = op.order_id
UNION ALL
SELECT
    'tech_sellers' AS category,
    ROUND(SUM(oi.price), 2) AS total_sales,
    ROUND(SUM(op.payment_value), 2) AS total_paid
FROM
    order_items oi
LEFT JOIN
    order_payments op
ON
    oi.order_id = op.order_id
LEFT JOIN 
    products p
ON
    oi.product_id = p.product_id
LEFT JOIN
    product_category_name_translation pt
ON
    p.product_category_name = pt.product_category_name
WHERE
    pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts');

/* 8. Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers? */

SELECT
	'overall' AS category,
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS `month`,
    ROUND(AVG(price), 2) AS total_sales,
    ROUND(AVG(payment_value), 2) AS total_paid
FROM
	orders o
LEFT JOIN
	order_items oi
ON 
	o.order_id = oi.order_id
LEFT JOIN
	order_payments op
ON
	oi.order_id = op.order_id
GROUP BY
	`month`
UNION ALL
SELECT
	'tech_sellers' AS category,
	DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS `month`,
    ROUND(AVG(price), 2) AS total_sales,
    ROUND(AVG(payment_value), 2) AS total_paid
FROM
	orders o
LEFT JOIN
	order_items oi
ON 
	o.order_id = oi.order_id
LEFT JOIN
	order_payments op
ON
	oi.order_id = op.order_id
LEFT JOIN
	products p
ON 
	p.product_id = oi.product_id
LEFT JOIN
	product_category_name_translation pt
ON
	p.product_category_name = pt.product_category_name
WHERE
    pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY
	`month`
ORDER BY
	`month`;

WITH monthly_totals AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS `month`,
        AVG(oi.price) AS total_sales,
        AVG(op.payment_value) AS total_paid
    FROM
        orders o
    LEFT JOIN
        order_items oi 
	ON 
		o.order_id = oi.order_id
    LEFT JOIN
        order_payments op 
	ON 
		oi.order_id = op.order_id
    GROUP BY
        `month`
),
tech_monthly_totals AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS `month`,
        AVG(oi.price) AS total_sales,
        AVG(op.payment_value) AS total_paid
    FROM
        orders o
    LEFT JOIN
        order_items oi 
	ON
		o.order_id = oi.order_id
    LEFT JOIN
        order_payments op 
	ON 
		oi.order_id = op.order_id
	LEFT JOIN
		products p
	ON 
		p.product_id = oi.product_id
	LEFT JOIN
		product_category_name_translation pt
	ON
		p.product_category_name = pt.product_category_name
	WHERE
		pt.product_category_name_english 
    IN
    ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
    'fixed_telephony', 'music', 'computers', 'watches_gifts')
    GROUP BY
        `month`
),
combined_totals AS (
	SELECT
		'overall' AS category,
        `month`,
        total_sales,
        total_paid
	FROM
		monthly_totals
	UNION ALL
    SELECT
		'tech_sellers' AS category,
        `month`,
        total_sales,
        total_paid
	FROM
		tech_monthly_totals
)
SELECT
	category,
    ROUND(AVG(total_sales), 2) AS avg_monthly_order,
    ROUND(AVG(total_paid), 2) AS avg_monthly_paid
FROM
	combined_totals
GROUP BY
	category;

-- overall:	115.57(avg_monthly_order), 	164.4(avg_monthly_paid - including freight cost etc.)
-- tech_sellers	138.87(avg_monthly_order),	188.46(avg_monthly_paid - including freight cost etc.)

-- In relation to the DELIVERY TIME:
/* 9. What’s the average time between the order being placed and the product being delivered? */ 

SELECT
	'overall' AS category,
	ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_delivery_days
FROM
	orders
UNION ALL
SELECT
	'tech_sellers' AS category,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_delivery_days
FROM 
	orders o
LEFT JOIN
	order_items oi
ON 
	o.order_id = oi.order_id
LEFT JOIN
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
IN
('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
'fixed_telephony', 'music', 'computers', 'watches_gifts');

-- Average delivery time:
-- overall - 12.10
-- tech_sellers - 12.52

/* 10. How many orders are delivered on time vs orders delivered with a delay? */ 

SELECT
	'overall' AS category,
	ROUND(AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)), 2) AS avg_delay_days
FROM
	orders
UNION ALL
SELECT
	'tech_sellers' AS category,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)), 2) AS avg_delay_days
FROM 
	orders o
LEFT JOIN
	order_items oi
ON 
	o.order_id = oi.order_id
LEFT JOIN
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
IN
('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
'fixed_telephony', 'music', 'computers', 'watches_gifts');

-- The average delay shows that the orders are delivered around 11 days EARLIER than the estimated indicates

SELECT 
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time', 'late') AS delivery_status,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentage_total
FROM 
    orders
GROUP BY 
    delivery_status
UNION ALL
SELECT 
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time (tech)', 'late (tech)') AS delivery_status,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentage_total
FROM 
    orders o
LEFT JOIN
	order_items oi
ON 
	o.order_id = oi.order_id
LEFT JOIN
	products p
ON
	oi.product_id = p.product_id
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
IN
('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
'fixed_telephony', 'music', 'computers', 'watches_gifts')
GROUP BY 
    delivery_status
ORDER BY
	delivery_status;

-- For both general sellers and tech sellers, around 10% of the orders were delayed and 90% delivered on time

/* 11. Is there any pattern for delayed orders, e.g. big products being delayed more often? */ 

-- Let's explore first the distribution of measurements

SELECT
	'overall' AS category,
	ROUND(MAX(product_length_cm * product_height_cm * product_width_cm), 2) AS max_vol,
    ROUND(MIN(product_length_cm * product_height_cm * product_width_cm), 2) AS min_vol,
    ROUND(AVG(product_length_cm * product_height_cm * product_width_cm), 2) AS avg_vol,
    ROUND(MAX(product_weight_g), 2) AS max_weight,
    ROUND(MIN(product_weight_g), 2) AS min_weight,
    ROUND(AVG(product_weight_g), 2) AS avg_weight
FROM
	products
UNION ALL
SELECT
	'tech_products' AS category,
	ROUND(MAX(product_length_cm * product_height_cm * product_width_cm), 2) AS max_vol,
    ROUND(MIN(product_length_cm * product_height_cm * product_width_cm), 2) AS min_vol,
    ROUND(AVG(product_length_cm * product_height_cm * product_width_cm), 2) AS avg_vol,
    ROUND(MAX(product_weight_g), 2) AS max_weight,
    ROUND(MIN(product_weight_g), 2) AS min_weight,
    ROUND(AVG(product_weight_g), 2) AS avg_weight
FROM
	products p
LEFT JOIN
	product_category_name_translation pt
ON 
	p.product_category_name = pt.product_category_name
WHERE
	pt.product_category_name_english 
IN
('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 
'fixed_telephony', 'music', 'computers', 'watches_gifts');

-- Tech products appear to be smaller and leaner than the other products, with and avg. of 5k cm3 and 700 g vs. 17k cm3 and 2k g

WITH overall_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
),
tech_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
    LEFT JOIN
        product_category_name_translation pt ON p.product_category_name = pt.product_category_name
    WHERE
        pt.product_category_name_english IN ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
)
SELECT 
    'overall' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time', 'late') AS delivery_status,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    overall_orders
GROUP BY 
    delivery_status
UNION ALL
SELECT 
    'tech_products' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time (tech)', 'late (tech)') AS delivery_status,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    tech_orders
GROUP BY 
    delivery_status
ORDER BY
    category, delivery_status;

-- There seems to be a slight increase on weight and volume on delayed products, but it's not particularly significant

WITH overall_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month_year
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
),
tech_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month_year
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
    LEFT JOIN
        product_category_name_translation pt ON p.product_category_name = pt.product_category_name
    WHERE
        pt.product_category_name_english IN ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
)
SELECT 
    'overall' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time', 'late') AS delivery_status,
    month_year,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    overall_orders
GROUP BY 
    delivery_status, month_year
UNION ALL
SELECT 
    'tech_products' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time (tech)', 'late (tech)') AS delivery_status,
    month_year,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    tech_orders
GROUP BY 
    delivery_status, month_year
ORDER BY
     month_year, category, delivery_status;

WITH overall_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month_year
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
),
tech_orders AS (
    SELECT 
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_diff,
        p.product_length_cm * p.product_height_cm * p.product_width_cm AS volume,
        p.product_weight_g AS weight,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month_year
    FROM 
        orders o
    LEFT JOIN
        order_items oi ON o.order_id = oi.order_id
    LEFT JOIN
        products p ON oi.product_id = p.product_id
    LEFT JOIN
        product_category_name_translation pt ON p.product_category_name = pt.product_category_name
    WHERE
        pt.product_category_name_english IN ('consoles_games', 'computers_accessories', 'pc_gamer', 'tablets_printing_image', 'electronics', 'audio', 'telephony', 'fixed_telephony', 'music', 'computers', 'watches_gifts')
)
SELECT 
    'overall' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time', 'late') AS delivery_status,
    month_year,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY month_year), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    overall_orders
GROUP BY 
    delivery_status, month_year
UNION ALL
SELECT 
    'tech_products' AS category,
    IF(order_delivered_customer_date <= order_estimated_delivery_date, 'on time (tech)', 'late (tech)') AS delivery_status,
    month_year,
    COUNT(*) AS count_orders,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY month_year), 2) AS percentage_total,
    ROUND(MIN(volume), 2) AS min_vol,
    ROUND(MAX(volume), 2) AS max_vol,
    ROUND(AVG(volume), 2) AS avg_vol,
    ROUND(MIN(weight), 2) AS min_weight,
    ROUND(MAX(weight), 2) AS max_weight,
    ROUND(AVG(weight), 2) AS avg_weight
FROM 
    tech_orders
GROUP BY 
    delivery_status, month_year
ORDER BY
    month_year, category, delivery_status;
    
-- There also appears to be a slight increase on delays around november, december and february, possibly because of christmas and discounts?
