USE Dannys_Dinner
GO

SELECT * FROM dbo.sales GO
SELECT * FROM dbo.menu GO
SELECT * FROM dbo.members GO


/*What is the total amount each customer spent at the restaurant?*/
SELECT
	s.customer_id
	,SUM( men.price )
FROM
	dbo.sales s
LEFT JOIN
	dbo.menu men
ON
	s.product_id = men.product_id
GROUP BY
	s.customer_id
GO



/* How many days has each customer visited the restaurant? */
SELECT
	customer_id
	,COUNT( DISTINCT( order_date ) ) AS visits
FROM
	dbo.sales
GROUP BY
	customer_id
GO


/* What was the first item from the menu purchased by each customer? */
WITH cte1 AS(
SELECT
	s.customer_id
	,s.order_date
	,m.product_name
	,RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ASC)			AS rank
	,ROW_NUMBER() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ASC)	AS row_num
FROM
	dbo.sales s
LEFT JOIN
	menu m
ON
	s.product_id = m.product_id
)
SELECT
	customer_id
	,product_name
FROM
	cte1
WHERE
	rank = 1
GO

/* Second solution */
SELECT
	customer_id
	,product_name
FROM
	cte1
WHERE
	row_num = 1
GO


/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
WITH cte1 AS(
SELECT
	s.product_id
	,m.product_name
	,COUNT(*)								AS purchased
	,RANK() OVER(ORDER BY COUNT(*) DESC)	AS rank
FROM
	dbo.sales s
LEFT JOIN
	dbo.menu m
ON
	s.product_id = m.product_id
GROUP BY
	s.product_id, m.product_name
)
SELECT
	product_name
	,purchased
FROM
	cte1
WHERE
	rank = 1
GO



/* Which item was the most popular for each customer? */
WITH cte1 AS(
SELECT
	s.customer_id
	,m.product_name
	,COUNT(*)														AS purchased
	,RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC)	AS rank
FROM
	dbo.sales s
LEFT JOIN
	dbo.menu m
ON
	s.product_id = m.product_id
GROUP BY
	s.customer_id, m.product_name
)
SELECT
	customer_id
	,product_name
FROM
	cte1
WHERE
	rank = 1
GO


/* Which item was purchased first by the customer after they became a member? */
WITH cte1 AS(
SELECT
	s.customer_id
	,s.product_id
	,me.product_name
	,m.join_date
	,s.order_date
	,RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date ) AS ranks
FROM
	dbo.sales s
LEFT JOIN
	dbo.members m
ON
	s.customer_id = m.customer_id
LEFT JOIN
	dbo.menu me
ON
	s.product_id = me.product_id
WHERE
	s.order_date > m.join_date
)
SELECT
	customer_id
	,product_name
FROM
	cte1
WHERE
	ranks = 1
GO

/* Which item was purchased just before the customer became a member? */
WITH cte1 AS(
SELECT
	s.customer_id
	,s.product_id
	,me.product_name
	,m.join_date
	,s.order_date
	,RANK() OVER( PARTITION BY s.customer_id ORDER BY s.order_date )		AS ranks
	,ROW_NUMBER() OVER( PARTITION BY s.customer_id ORDER BY s.order_date )	AS row_num
FROM
	dbo.sales s
LEFT JOIN
	dbo.members m
ON
	s.customer_id = m.customer_id
LEFT JOIN
	dbo.menu me
ON
	s.product_id = me.product_id
WHERE
	s.order_date <= m.join_date
)
SELECT
	customer_id
	,product_name
FROM
	cte1
WHERE
	row_num = 3
GO

/* What is the total items and amount spent for each member before they became a member? */
SELECT
	s.customer_id
	,COUNT( * )				AS items
	,SUM( me.price )		AS total_price
FROM
	dbo.sales s
LEFT JOIN
	dbo.members m
ON
	s.customer_id = m.customer_id
LEFT JOIN
	dbo.menu me
ON
	s.product_id = me.product_id
WHERE
	s.order_date <= m.join_date
GROUP BY
	s.customer_id
ORDER BY
	customer_id ASC

/* If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */\

WITH cte1 AS(
SELECT
	s.customer_id
	,m.product_name
	,m.price
	,CASE
		WHEN m.product_name = 'sushi' THEN m.price * 2
		ELSE m.price
	END AS points
FROM
	dbo.sales s
LEFT JOIN
	dbo.menu m
ON
	s.product_id = m.product_id
)
SELECT
	customer_id
	,SUM( points ) AS points
FROM
	cte1
GROUP BY
	customer_id
GO

/* In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January? */

WITH cte1 AS(
SELECT
	s.customer_id
	,m.product_name
	,m.price
	,s.order_date
	,me.join_date
	,DATEADD( day, 7 ,me.join_date ) AS max_day_promo
FROM
	dbo.sales s
LEFT JOIN
	dbo.menu m
ON
	s.product_id = m.product_id
LEFT JOIN
	dbo.members me
ON
	s.customer_id = me.customer_id
WHERE
	s.order_date >= me.join_date
)

SELECT
	customer_id
	--,order_date
	--,join_date
	--,max_day_promo
	,price
	,CASE
		WHEN order_date <= max_day_promo THEN price *2
		WHEN order_date > max_day_promo AND product_name = 'sushi' THEN price *2
		ELSE price 
	END AS promo_points
	FROM
		cte1
GO
