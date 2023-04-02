DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

UPDATE customer_orders
SET 
	exclusions = case exclusions when 'null' then null else exclusions end,
	extras = case extras when 'null' then null else extras end
GO


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

UPDATE runner_orders
SET cancellation = ''
WHERE cancellation IS NULL


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" int,
  "toppings" int
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

 INSERT INTO pizza_recipes
(pizza_id, toppings) 
values
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);
GO


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


USE Pizza_runner
GO




/* How many pizzas were ordered? */

SELECT
	COUNT(*) AS ordered_pizzas
FROM
	[dbo].[customer_orders]
GO -- 14

/* How many unique customer orders were made? */

SELECT
	COUNT( DISTINCT(customer_id) ) AS customer_orders
FROM
	[dbo].[customer_orders]
GO -- 5

/* How many successful orders were delivered by each runner? */

SELECT
	COUNT( * ) AS successful_orders
FROM
	[dbo].[runner_orders]
WHERE
	pickup_time NOT LIKE 'null'
GO -- 8 

/* How many of each type of pizza was delivered? */

SELECT
	co.pizza_id
	,COUNT( DISTINCT( ro.pickup_time ) ) AS number_of_pizzas
FROM
	[dbo].[customer_orders] co
INNER JOIN
	[dbo].[runner_orders] ro
ON
	co.order_id = ro.order_id
WHERE
	ro.pickup_time NOT LIKE 'null'
GROUP BY 
	co.pizza_id
GO

/* How many Vegetarian and Meatlovers were ordered by each customer? */

SELECT
	CONVERT( varchar, pn.pizza_name )		AS pizza_name
	,COUNT( DISTINCT( ro.pickup_time ) )	AS number_of_pizzas
FROM
	[dbo].[customer_orders] co
INNER JOIN
	[dbo].[runner_orders] ro
ON
	co.order_id = ro.order_id
LEFT JOIN
	[Pizza_runner].[dbo].[pizza_names] pn
ON
	co.pizza_id = pn.pizza_id
WHERE
	ro.pickup_time NOT LIKE 'null'
GROUP BY 
	CONVERT( varchar, pn.pizza_name )
GO

/* What was the maximum number of pizzas delivered in a single order? */

WITH cte1 AS(
SELECT
	order_id
	,COUNT( pizza_id )	AS pizzas_quantity
FROM
	[dbo].[customer_orders]
GROUP BY
	order_id
)
SELECT MAX( pizzas_quantity ) FROM cte1 GO

/* For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */

WITH cte1 AS (
SELECT
	co.customer_id
	,co.exclusions							AS exclusions
	,co.extras
	--,COALESCE( ro.cancellation, '')			AS cancellation
FROM
	[dbo].[customer_orders] co
JOIN
	[dbo].[runner_orders] ro
ON
	co.order_id = ro.order_id
WHERE
	COALESCE( ro.cancellation, '') NOT LIKE '%Cancellation'
)
SELECT
	customer_id
	,COUNT(exclusions)
FROM
	cte1
GROUP BY
	customer_id



/* How many pizzas were delivered that had both exclusions and extras? */


/* How many pizzas were delivered that had both exclusions and extras? */ 


/* What was the total volume of pizzas ordered for each hour of the day? */

SELECT
	CONVERT( smalldatetime, order_time, 108 )				AS order_hour
	,COUNT( DATEPART( HOUR, order_time) )					AS total_orders_by_hour
FROM
	[dbo].[customer_orders]
GROUP BY
	CONVERT( smalldatetime, order_time, 108 )
GO

/* What was the volume of orders for each day of the week? */

SELECT
	DATEPART( hour , order_time )	 	AS order_day
	,COUNT( DATEPART( DAY, order_time) )	AS total_orders_by_day
FROM
	[dbo].[customer_orders]
GROUP BY
	DATEPART( hour , order_time )
GO


/* How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */

SELECT 
	DATEPART(week, registration_date) as RegistrationWeek
	,count(runner_id) as RunnerRegistrated
FROM 
	runners
GROUP BY 
	DATEPART(week, registration_date);

/* What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? */

SELECT
	runner_id
	,AVG( CAST( SUBSTRING( duration, 1, 2 ) AS int ) )	AS average_time
FROM
	[Pizza_runner].[dbo].[runner_orders]
WHERE
	duration NOT LIKE 'null'
GROUP BY
	runner_id
GO

/* Is there any relationship between the number of pizzas and how long the order takes to prepare? */

WITH cte1 AS(
SELECT
	 co.order_id
	 ,CAST( co.order_time AS time )						AS order_time
	 ,CAST( CAST( ro.pickup_time AS datetime ) AS time)	AS pickup_time
FROM
	[Pizza_runner].[dbo].[customer_orders] co
LEFT JOIN
	[Pizza_runner].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE
	ro.pickup_time NOT LIKE 'null'

)
SELECT
	--order_id
	COUNT(order_id)							AS number_of_orders
	,DATEDIFF(minute, order_time ,pickup_time) 	AS prepare_time_in_minutes
FROM
	cte1
GROUP BY
	order_id, DATEDIFF(minute, order_time ,pickup_time)
ORDER BY 
	order_id

/*What was the average distance travelled for each customer?*/

SELECT
	 co.customer_id
	 ,ROUND( AVG( CAST( REPLACE(ro.distance, 'km', '' ) AS float ) ), 2 ) AS average_distance
FROM
	[Pizza_runner].[dbo].[customer_orders] co
LEFT JOIN
	[Pizza_runner].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE
	ro.distance NOT LIKE 'null'
GROUP BY 
	co.customer_id
GO

/*What was the difference between the longest and shortest delivery times for all orders?*/

SELECT
	MAX( CAST( LEFT(duration,2) AS int ) ) - MIN( CAST( LEFT(duration,2) AS int ) ) AS delivery_difference_in_minutes
FROM
	[dbo].[runner_orders]
WHERE
	duration NOT LIKE 'null'

/*What was the average speed for each runner for each delivery and do you notice any trend for these values?*/

SELECT
	runner_id
	,ROUND( AVG( CAST( REPLACE(distance, 'km', '' ) AS float ) / CAST( LEFT(duration,2) AS float ) ), 2 ) AS average_speed
FROM
	[dbo].[runner_orders]
WHERE
	duration NOT LIKE 'null'
GROUP BY 
	runner_id

/*What is the successful delivery percentage for each runner?*/

SELECT
	runner_id
	,(COUNT(order_id) - (SELECT COUNT(order_id) FROM [dbo].[runner_orders] WHERE pickup_time LIKE 'null'))/ COUNT(order_id) * 100 
FROM
	[dbo].[runner_orders]
GROUP BY
	runner_id

/* What are the standard ingredients for each pizza? */
--CROSS APPLY string_split (CAST([toppings] AS varchar), ',')

WITH cte1 AS(
SELECT
	pizza_id
	,toppings
FROM
	[dbo].[pizza_recipes]
WHERE
	pizza_id = 1
),cte2 AS(
SELECT
	pizza_id
	,toppings
FROM
	[dbo].[pizza_recipes]
WHERE
	pizza_id = 2
)
SELECT
	cte1.toppings
FROM
	cte1
INNER JOIN cte2 ON cte1.toppings = cte2.toppings
GO

/* If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?*/ 

WITH cte1 AS(
SELECT
	co.order_id
	,pn.pizza_name
	,ro.runner_id
	,CASE
		WHEN
			CAST( pn.pizza_name AS varchar ) = 'Meatlovers' THEN 12
			ELSE 10
	END AS price
FROM
	[dbo].[customer_orders] co 
INNER JOIN
	[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id
INNER JOIN
	[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE
	ro.cancellation = ''
)
SELECT
	runner_id
	,CAST( pizza_name AS varchar )	AS pizza_name
	,SUM(price) AS total_price
FROM
	cte1
GROUP BY runner_id, CAST( pizza_name AS varchar ) 


/* The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. */

DROP TABLE IF EXISTS dbo.ratings
CREATE TABLE ratings (
	order_id int
	,rating int
	)

INSERT INTO dbo.ratings (order_id, rating)
VALUES(1,3),(2,5),(3,2),(4,3),(5,4),(6,5),(7,2),(8,3),(9,1),(10,3)

SELECT * FROM ratings

/* Using your newly generated table - 
can you join all of the information together to form a table which has the following information for successful deliveries? 
customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas*/


SELECT
	co.customer_id
	,co.order_id
	,ro.runner_id
	,r.rating
	,co.order_time
	,ro.pickup_time
	,DATEDIFF(MINUTE, order_time,CAST(pickup_time AS datetime) ) AS minute_difference
	,AVG( CAST(SUBSTRING(ro.distance, 1,2) AS int) * 60 / CAST(SUBSTRING(ro.duration, 1,2) AS int) ) AS average_speed
	,COUNT(co.order_id) AS number_of_pizzas
FROM
	customer_orders co
LEFT JOIN
	runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN
	ratings r ON co.order_id = r.order_id
WHERE
	pickup_time NOT LIKE 'null'
GROUP BY 
	co.customer_id
	,co.order_id
	,ro.runner_id
	,r.rating
	,co.order_time
	,ro.pickup_time

/* If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries? */

WITH cte1 AS (
SELECT
	co.order_id
	,ro.runner_id
	,TRIM( REPLACE(ro.distance, 'km', '') ) AS distance_km
	,pn.pizza_name
	,CASE
		WHEN CONVERT( varchar, pn.pizza_name) = 'Meatlovers' THEN 12
		ELSE 10
	END AS cost
FROM
	customer_orders co
LEFT JOIN
	pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN
	runner_orders ro ON co.order_id = ro.order_id
WHERE
	ro.distance NOT LIKE 'null'
)
SELECT
	runner_id
	,SUM(cost) AS pizza_cost
	,CEILING( SUM( CAST(distance_km AS decimal (8,2)) * 0.3) ) AS runner_cost
	,SUM(cost) - CEILING( SUM( CAST(distance_km AS decimal (8,2)) * 0.3) ) AS cost_difference
FROM
	cte1
GROUP BY
	runner_id
GO


	













