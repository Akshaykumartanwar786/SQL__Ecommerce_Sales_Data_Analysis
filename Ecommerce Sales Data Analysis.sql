

--Q1. Total Revenue (order value) 
select round(sum(ORDER_TOTAL),2) as revenue 
from [Orders Data]


--Q2. Total Revenue (order value) by top 25 Customers 
select  sum(x.revenue) total_revenue
      from (
             select top 25 CUSTOMER_KEY, SUM(ORDER_TOTAL) as revenue
             from [Orders Data]
             group by CUSTOMER_KEY
             order by revenue desc
			 ) as x

--Q3. Total number of orders 
select count(ORDER_NUMBER) total_orders
from [Orders Data]

--Q4. Total orders by top 10 customers
select sum(x.orders)   
      from   (
              select top 10 CUSTOMER_KEY, count(ORDER_NUMBER) as orders
              from [Orders Data]
              group by CUSTOMER_KEY
              order by orders desc
			  ) as x

--Q6 number of customer ordered once 
select count(x.CUSTOMER_KEY)  
    from     (
              select CUSTOMER_KEY, COUNT(ORDER_NUMBER) as orders 
              from [Orders Data]
              group by CUSTOMER_KEY
              having COUNT(ORDER_NUMBER) = 1
			  ) as x

--Q7. Number of customers ordered multiple times
select COUNT(x.CUSTOMER_KEY)  
     from   (
              select CUSTOMER_KEY, COUNT(ORDER_NUMBER) as orders 
              from [Orders Data]
              group by CUSTOMER_KEY
              having COUNT(ORDER_NUMBER) > 1
			  ) as x

--Q8. Number of customers referred to other customers 
from [Customer Data]
where [Referred Other customers] = 'y'


--Q9. Which Month have maximum Revenue? 
select top 1 month(ORDER_DATE) as month, sum(ORDER_TOTAL) as revenue
from [Orders Data]
group by month(ORDER_DATE)
order by revenue desc


--Q10. Number of customers are inactive (that haven't ordered in the last 60 days) 
select count(CUSTOMER_KEY)
from [Orders Data]
where ORDER_TOTAL = 0 and 
ORDER_DATE > DATEADD(DAY,-60, (select max(order_date) from [Orders Data]))
					

--Q11. Growth Rate (%) in Orders (from Nov’15 to July’16)  
WITH RevenueData 
AS ( SELECT order_total,FORMAT(order_date, 'yyyy-MM') AS YearMonth
     FROM [Orders Data]
     WHERE order_date BETWEEN '2015-11-01' AND '2016-07-31'
    ),
SummarizedRevenue 
AS ( SELECT YearMonth, count(ORDER_TOTAL) AS Total_order
     FROM RevenueData
     GROUP BY YearMonth
    ),
RevenueGrowth 
AS (  SELECT
      MAX(CASE WHEN YearMonth = '2015-11' THEN Total_order END) AS Nov15Revenue,
      MAX(CASE WHEN YearMonth = '2016-07' THEN Total_order END) AS Jul16Revenue
      FROM SummarizedRevenue
     )
SELECT (Jul16Revenue - Nov15Revenue) * 100.0 / Nov15Revenue AS GrowthRatePercentage
FROM RevenueGrowth;


--Q12. Growth Rate (%) in Revenue (from Nov'15 to July'16) 
WITH RevenueData 
AS ( SELECT order_total, FORMAT(order_date, 'yyyy-MM') AS YearMonth
     FROM [Orders Data]
     WHERE order_date BETWEEN '2015-11-01' AND '2016-07-31'
     ),
SummarizedRevenue
AS ( SELECT YearMonth, SUM(order_total) AS TotalRevenue
     FROM RevenueData 
	 GROUP BY YearMonth
    ),
RevenueGrowth 
AS ( SELECT
     MAX(CASE WHEN YearMonth = '2015-11' THEN TotalRevenue END) AS Nov15Revenue,
     MAX(CASE WHEN YearMonth = '2016-07' THEN TotalRevenue END) AS Jul16Revenue
     FROM SummarizedRevenue
    )
SELECT (Jul16Revenue - Nov15Revenue) * 100.0 / Nov15Revenue AS GrowthRatePercentage
FROM RevenueGrowth


--Q13. What is the percentage of Male customers exists?
with a
as ( select COUNT(Gender) as total_gender
     from [Customer Data]
	),
b 
as ( select COUNT(Gender) as male_gender
     from [Customer Data]
	 where Gender = 'm'
	 )
select (male_gender*100/total_gender) as percentage_male
from a,b


--Q14. Which location have maximum customers?  
select top 1 [Location], COUNT(CUSTOMER_ID) total_customer
from [Customer Data] 
group by [Location]
order by total_customer desc 


--Q15. How many orders are returned? (Returns can be found if the order total value is negative value)  
select count(ORDER_TOTAL)
from [Orders Data]
where ORDER_TOTAL < 0


--Q16. Which Acquisition channel is more efficient in terms of customer acquisition? 
select top 1 [Acquired Channel], count([Referred Other customers]) as counts
from [Customer Data]
where [Referred Other customers] = 'Y'
group by [Acquired Channel]
order by counts desc 


--Q17. Which location having more orders with discount amount?  
select top 1 [Location], COUNT(ORDER_NUMBER) as order_count
from [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
where DISCOUNT > 0
group by [Location]
order by order_count desc


--Q18. Which location having maximum orders delivered in delay?  
select top 1 [Location], count(DELIVERY_STATUS) as count_delivery
from [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
where DELIVERY_STATUS = 'late'
group by [Location] 
order by count_delivery desc

--Q19. What is the percentage of customers who are males acquired by APP channel? 
with a
as ( select count(*) as total_customer
     from [Customer Data]
    ),
b 
as ( select COUNT(*) male_customer
     from [Customer Data]
     where Gender = 'm' and [Acquired Channel] = 'app'
    )

select (male_customer*100/total_customer) as percentage_male_customer
from a,b


--Q20. What is the percentage of orders got canceled?  
with a
as  ( select convert(float,count(*)) as total_count
     from [Orders Data]
	 ),
b
as ( select count(*) total_cancelled
     from [Orders Data]
	 where ORDER_STATUS = 'cancelled'
	)

select (total_cancelled*100/total_count) as percentage_order_cancelled
from a,b


--Q21. What is the percentage of orders done by happy customers 
--     (Note: Happy customers mean customer who referred other customers)? 
with a
as ( select convert(float,count([Referred Other customers])) as total_count
     from [Customer Data]
	 ),
b 
as ( select COUNT(*) as yes_count
     from [Customer Data]
	 where [Referred Other customers] = 'y'
	 )
select (yes_count*100/total_count) as total_percentage
from a,b;


-- Q22. Which Location having maximum customers through reference?  
select top 1 Location,COUNT(CUSTOMER_ID) as cust_count
from [Customer Data]
where [Referred Other customers]='y'
group by Location
order by cust_count desc


--Q23. What is order_total value of male customers who are belongs to Chennai and Happy customers 
--     (Happy customer definition is same in question 21)?  

select sum(ORDER_TOTAL)
from [Customer Data] as c
join 
[Orders Data] as o
on c.CUSTOMER_KEY =  o.CUSTOMER_KEY
where Gender = 'm' and [Referred Other customers] = 'y' and Location = 'chennai'



--Q24. Which month having maximum order value from male customers belongs to Chennai? 
select top 1 MONTH(ORDER_DATE) as months, sum(ORDER_TOTAL) as total
from [Customer Data] as c
join
[Orders Data] as o
on c.CUSTOMER_KEY = o.CUSTOMER_KEY
where Gender = 'm' and Location = 'chennai'
group by MONTH(ORDER_DATE)
order by total desc


--Q26. Prepare at least 5 additional analysis on your own? 
-- 1. Gender-wise Order Analysis
SELECT C.Gender, COUNT(O.ORDER_NUMBER) AS OrderCount, SUM(O.ORDER_TOTAL) AS TotalOrderValue
FROM [Customer Data] as C
JOIN 
[Orders Data] as O 
ON C.CUSTOMER_KEY = O.CUSTOMER_KEY
GROUP BY C.Gender
ORDER BY TotalOrderValue DESC


-- 2.  Average Order Value by Gender
SELECT C.Gender, AVG(O.ORDER_TOTAL) AS AverageOrderValue
FROM [Orders Data] as o
JOIN 
[Customer Data] as c
ON O.CUSTOMER_KEY = C.CUSTOMER_KEY
GROUP BY C.Gender
ORDER BY AverageOrderValue DESC

-- 3.Gender Distribution by Location
SELECT Location, Gender, COUNT(*) AS CustomerCount
FROM [Customer Data]
GROUP BY Location, Gender
ORDER BY Location, Gender

-- 4.  Order Status Distribution
SELECT ORDER_STATUS, COUNT(ORDER_NUMBER) AS TotalOrders
FROM [Orders Data]
GROUP BY ORDER_STATUS
ORDER BY TotalOrders DESC

-- 5.Repeat Customers Analysis
WITH Customer_Counts
AS ( SELECT 
     CUSTOMER_KEY,
     COUNT(ORDER_NUMBER) AS OrderCount
     FROM [Orders Data]
     GROUP BY CUSTOMER_KEY
     )
SELECT SUM(CASE WHEN OrderCount > 1 THEN 1 ELSE 0 END) AS RepeatCustomers
from Customer_Counts


/* Q25. What are number of discounted orders ordered by 
       female customers who were acquired by website from Bangalore delivered on time?  */
select COUNT(x.ORDER_NUMBER)  as female_order
    from ( select ORDER_NUMBER,Gender,[Acquired Channel],DELIVERY_STATUS
           from [Customer Data] as c
           join 
           [Orders Data] as o 
           on c.CUSTOMER_KEY = o.CUSTOMER_KEY
           where DISCOUNT > 0 and DELIVERY_STATUS = 'on-time' and Location = 'bangalore'
   	        ) as x
   	       where x.Gender = 'f' and [Acquired Channel] = 'website'


/* Q26. Number of orders by month based on order status (Delivered vs. canceled vs. etc.) 
        Split of order status by month */
select MONTH(ORDER_DATE) as months, ORDER_STATUS, count(ORDER_NUMBER) as total,
ROW_NUMBER() over ( partition by MONTH(ORDER_DATE) order by MONTH(ORDER_DATE))
from [Orders Data]
group by MONTH(ORDER_DATE),ORDER_STATUS
order by months asc , ORDER_STATUS asc



--Q27. Number of orders by month based on delivery status 
select MONTH(ORDER_DATE) as months, DELIVERY_STATUS,COUNT(ORDER_NUMBER) as total_orders
from [Orders Data]
group by MONTH(ORDER_DATE),DELIVERY_STATUS
order by months asc


--Q28. Month-on-month growth in OrderCount and Revenue (from Nov’15 to July’16) 
WITH MonthlyData 
as   (  SELECT
        MONTH(order_date) AS Month,
        COUNT(order_number) AS OrderCount,
        SUM(order_total) AS Revenue
        FROM [Orders Data]
        WHERE order_date BETWEEN '2015-11-01' AND '2016-07-31'
        GROUP BY MONTH(order_date)
		),
GrowthData 
AS  (   SELECT
        Month,
        OrderCount,
        Revenue,
        LAG(OrderCount) OVER (ORDER BY  Month) AS PrevOrderCount,
        LAG(Revenue) OVER (ORDER BY  Month) AS PrevRevenue
        FROM MonthlyData
)
SELECT Month, OrderCount, Revenue,(OrderCount-PrevOrderCount) as order_growth,
(Revenue-PrevRevenue) as revenue_growth
FROM GrowthData
ORDER BY Month


/*Q29. Month-wise split of total order value of the top 50 customers 
      (The top 50 customers need to identified based on their total order value)*/
with customer
as ( select CUSTOMER_KEY, sum(ORDER_TOTAL) as customer_total
     from [Orders Data]
	 group by CUSTOMER_KEY
	),
top50
as ( select top 50 CUSTOMER_KEY, customer_total
     from customer
	 order by customer_total desc
	),
months_wise
as ( select CUSTOMER_KEY, MONTH(ORDER_DATE) as months, sum(ORDER_TOTAL) as total_orders
     from [Orders Data]
	 where CUSTOMER_KEY in (select CUSTOMER_KEY from top50)
	 group by CUSTOMER_KEY, MONTH(ORDER_DATE)
	 )
select months, CUSTOMER_KEY, total_orders
from months_wise
order by months, CUSTOMER_KEY, total_orders



/* Q30. Month-wise split of new and repeat customers. 
        New customers mean, new unique customer additions in any given month*/
WITH FirstOrderMonth 
AS  ( SELECT
      CUSTOMER_KEY,
      MIN(ORDER_DATE) AS FirstOrderDate,
      FORMAT(MIN(ORDER_DATE), 'yyyy-MM') AS FirstOrderMonth
      FROM [Orders Data]
      GROUP BY CUSTOMER_KEY
     ),
MonthWiseCustomerSplit
AS (   SELECT
       FORMAT(O.ORDER_DATE, 'yyyy-MM') AS OrderMonth,
       O.CUSTOMER_KEY,
       CASE WHEN FORMAT(O.ORDER_DATE, 'yyyy-MM') = F.FirstOrderMonth THEN 'New' ELSE 'Repeat'
       END AS CustomerType
       FROM [Orders Data] O
       JOIN
       FirstOrderMonth F 
	   ON O.CUSTOMER_KEY = F.CUSTOMER_KEY
      )
SELECT OrderMonth, CustomerType, COUNT(DISTINCT CUSTOMER_KEY) AS CustomerCount
FROM MonthWiseCustomerSplit
GROUP BY OrderMonth, CustomerType
ORDER BY OrderMonth, CustomerType


/* Q31. Write stored procedure code which take inputs as location & month, and 
        the output is total_order value and number of orders by Gender, 
        Delivered Status for given location & month. Test the code with different options*/

CREATE PROCEDURE Order_Location_Month @Location varchar(50), @Month INT
AS
SELECT Gender,ORDER_STATUS,COUNT(ORDER_NUMBER) AS NumberOfOrders,
       SUM(ORDER_TOTAL) AS TotalOrderValue
FROM [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
WHERE Location = @Location AND MONTH(ORDER_DATE) = @Month
GROUP BY Gender, ORDER_STATUS

exec Order_Location_Month 'chennai', '5'


/*Q32. Create Customer 360 File with Below Columns using Orders Data & Customer Data
Customer_ID
CONTACT_NUMBER
Referred Other customers
Gender
Location
Acquired Channel
No.of Orders
Total Order_vallue
Total orders with discount
Total Orders received late
Total Orders returned
Maximum Order value
First Transaction Date
Last Transaction Date
Tenure_Months  (Tenure is defined as the number of months between first & last transaction)
No_of_orders_with_Zero_value

Note: Customer360 is data aggregated at customer level (one record for one customer)*/
-- Create Customer360 View/Table
SELECT C.CUSTOMER_ID, C.CONTACT_NUMBER,
C.[Referred Other customers], C.Gender,C.Location,
C.[Acquired Channel],
COUNT(O.ORDER_NUMBER) AS No_of_Orders,
SUM(O.ORDER_TOTAL) AS Total_Order_Value,
SUM(CASE WHEN O.DISCOUNT > 0 THEN 1 ELSE 0 END) AS Total_Orders_with_Discount,
SUM(CASE WHEN O.DELIVERY_STATUS = 'Late' THEN 1 ELSE 0 END) AS Total_Orders_Received_Late,
SUM(CASE WHEN O.ORDER_STATUS = 'Returned' THEN 1 ELSE 0 END) AS Total_Orders_Returned,
MAX(O.ORDER_TOTAL) AS Maximum_Order_Value,
MIN(O.ORDER_DATE) AS First_Transaction_Date,
MAX(O.ORDER_DATE) AS Last_Transaction_Date,
DATEDIFF(MONTH, MIN(O.ORDER_DATE), MAX(O.ORDER_DATE)) AS Tenure_Months,
SUM(CASE WHEN O.ORDER_TOTAL = 0 THEN 1 ELSE 0 END) AS No_of_Orders_with_Zero_Value
FROM
[Customer Data] C
LEFT JOIN
[Orders Data] O ON C.CUSTOMER_KEY = O.CUSTOMER_KEY

GROUP BY C.CUSTOMER_ID, C.CONTACT_NUMBER,
C.[Referred Other customers], C.Gender,
C.Location, C.[Acquired Channel]


--Q33. Total Revenue, total orders by each location
select [Location], sum(ORDER_TOTAL) as total_revenue, count(ORDER_NUMBER) as total_order
from [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
group by [Location]


--Q34. Total revenue, total orders by customer gender
select Gender, sum(ORDER_TOTAL) as total_revenue, count(ORDER_NUMBER) as total_order
from [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
group by Gender

--Q35. Which location of customers cancelling orders maximum?
select top 1 [Location], count(ORDER_STATUS) as cancelled_order
from [Customer Data] as c
join 
[Orders Data] as o 
on c.CUSTOMER_KEY = o.CUSTOMER_KEY
where ORDER_STATUS = 'cancelled'
group by [Location]
order by cancelled_order desc

--Q36. Total customers, Revenue, Orders by each Acquisition channel
select [Acquired Channel], count(distinct(CUSTOMER_ID)) as total_customer, sum(ORDER_TOTAL) as total_revenue,
count(ORDER_NUMBER) as  total_orders
from [Customer Data] as c
join 
[Orders Data] as o 
on c.CUSTOMER_KEY = o.CUSTOMER_KEY
group by [Acquired Channel]

--Q37. Which acquisition channel is good in terms of revenue generation, maximum orders, repeat purchasers?
with repeat_customer
as ( select CUSTOMER_ID, COUNT(CUSTOMER_ID) as counts
     from [Customer Data] as c
	 join 
	 [Orders Data] as o
	 on c.CUSTOMER_KEY = o.CUSTOMER_KEY
	 group by CUSTOMER_ID
	 having COUNT(CUSTOMER_ID) > 1
	 ),
channel 
as ( select [Acquired Channel], sum(ORDER_TOTAL) as revenue, count(ORDER_NUMBER) as total_orders,
     count(CUSTOMER_ID) total_customer
     from [Customer Data] as c
	 join 
	 [Orders Data] as o
	 on c.CUSTOMER_KEY = o.CUSTOMER_KEY
	 where CUSTOMER_ID in ( select CUSTOMER_ID from repeat_customer)
	 group by [Acquired Channel]
	 )
select top 1 [Acquired Channel], revenue, total_orders, total_customer
from channel
order by total_orders desc, revenue desc, total_customer desc
	 
	 
--Q39. Prepare at least 5 additional analysis on your own?

-- 1 average orders by locations.
SELECT Location, AVG(ORDER_TOTAL) AS avg_order
FROM [Orders Data] as o
join 
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY Location
ORDER BY avg_order DESC;

-- 2 total and percentage of orders that were delivered late or on time.
SELECT DELIVERY_STATUS, COUNT(ORDER_TOTAL) AS Number_of_Orders,
(COUNT(ORDER_TOTAL) * 100.0 / (SELECT COUNT(*) FROM [Orders Data])) AS Percentage_of_Orders
FROM [Orders Data] as o
join
[Customer Data] as c
on o.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY DELIVERY_STATUS;


-- 3 Revenue Contribution by Customer Gender and Location
SELECT C.Gender, C.Location, SUM(O.ORDER_TOTAL) AS TotalRevenue
FROM [Customer Data] C
JOIN [Orders Data] O ON C.CUSTOMER_KEY = O.CUSTOMER_KEY
GROUP BY C.Gender, C.Location
ORDER BY C.Gender, C.Location;

-- 4. Order Distribution by Month and Order Status
SELECT FORMAT(ORDER_DATE, 'yyyy-MM') AS OrderMonth, ORDER_STATUS,
COUNT(ORDER_NUMBER) AS OrderCount
FROM [Orders Data]
GROUP BY FORMAT(ORDER_DATE, 'yyyy-MM'), ORDER_STATUS
ORDER BY OrderMonth, ORDER_STATUS

-- 5. Monthly Revenue Trend
SELECT FORMAT(ORDER_DATE, 'yyyy-MM') AS OrderMonth, 
SUM(ORDER_TOTAL) AS TotalRevenue
FROM  [Orders Data]
GROUP BY  FORMAT(ORDER_DATE, 'yyyy-MM')
ORDER BY OrderMonth

