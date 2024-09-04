                                                                            //*******WALMART_SALES********//
                                                                            
                                                                            
create database walmart_sales;
use walmart_sales;
show tables;
select * from walmart;
WHERE coalesce(`invoice id` ,branch,city ,`customer type`,gender,`product line`,`unit price` ,quantity ,`tax 5%`,total ,Date , Time,payment,cogs,`gross margin percentage`,`gross income`,rating) IS NULL;
alter table walmart
add column  time_of_day varchar(10);
set sql_safe_updates=0; employeesdetailsemployees
update walmart
set time_of_day=case
     when hour(Time) < 12 then "morning"
     when hour(Time) < 18 then "afternoon"
	else "evening"
    end;
alter table walmart
add column day_name text ;  
update walmart
set day_name = dayname(str_to_date(date, "%Y-%m-%d"));
alter table walmart 
add column  month_name  text ; 
update walmart 
set month_name=monthname(str_to_date(date, "%Y-%m-%d"));
alter table walmart 
change `invoice id` Invoice_ID  text;  
alter table walmart 
change `Customer type` Customer_type text;                   
                
alter table walmart 
change `Product line` Product_line text,
change `Unit price`  Unit_price double;
alter table walmart 
change  `Tax 5%` vat double,
change `gross margin percentage` gross_margin_percentage double,
change `gross income` gross_income double;
   
   
   select *from walmart;


                                                       /*** Business Questions To Answer


                                                            Generic Question  ****/

-- 1. How many unique cities does the data have?

      select count(distinct city) as unique_cities from walmart;


 -- 2. In which city is each branch?
  
      select distinct city,branch from walmart;
 
 
 
                                                 ------------- /***  Product  ***/-------------
 -- 1. How many unique product lines does the data have?
 
       select count(distinct product_line) as "unique_product_lines" from walmart;
 
 -- 2. What is the most common payment method?
 
 SELECT payment, COUNT(*) as "most_common_payment_method"      -- (OR)   select max(payment) as common_payment_method from walmart;
 FROM walmart
GROUP BY payment
ORDER BY most_common_payment_method DESC
LIMIT 1;
 
 
 
 -- 3. What is the most selling product line?
 
 
WITH LINE AS (
SELECT Product_line , SUM(QUANTITY)AS "Most_selling_product_line" FROM WALMART
GROUP BY Product_line
ORDER BY COUNT(*) DESC)
SELECT * FROM LINE
WHERE Most_selling_product_line=(SELECT MAX(Most_selling_product_line) FROM LINE);
 
 
 
 -- 4. What is the total revenue by month?
    select * from walmart;
    
    select month_name  ,sum(total) as total_revenue  from walmart
    group by month_name;
    
 
 -- 5. What month had the largest COGS?
 select * from walmart;
 
                                  /*****/
 with large as (
 select month_name,sum(cogs) as largest_COGS 
  from walmart
  group by month_name
  order by largest_COGS desc)
  select * from large
  where largest_COGS =(select max(largest_COGS)from large);
  
                                /****************/
  
 select month_name,sum(cogs) AS highest_cogs
 from walmart
 group by month_name
 having highest_cogs=(select max(largest_cogs)
 from(select month_name,sum(cogs) as largest_COGS 
 from walmart
  group by month_name) as max_value);
                                          /*********/
  with sum_cogs as (select month_name,sum(cogs) as largest_COGS 
 from walmart
  group by month_name),
  max_cogs as (select max(largest_cogs) as largest_cogs
 from sum_cogs) 
 select month_name,mc.largest_cogs
 from sum_cogs sc
 join max_cogs mc
 ON sc.largest_COGS=mc.largest_cogs;
 
                                /*********/
 
 -- 6. What product line had the largest revenue?
 
 select * from walmart;
 
 
 WITH REVENUE AS (
 select Product_line, sum(Total) as " large_Revenue"  FROM walmart
 group by product_line
 )
 select * from REVENUE
 where large_Revenue=(select max(large_Revenue)
 from revenue);
 
 
 -- 7. What is the city with the largest revenue?
 
       SELECT * FROM walmart;
       
       
WITH  LARGE_C AS (
SELECT DISTINCT(CITY), SUM(TOTAL) AS  "REVENUE"   FROM walmart
GROUP BY CITY)
SELECT * FROM LARGE_C
WHERE REVENUE= (SELECT MAX( REVENUE) FROM LARGE_C);
 
 
 
 
 -- 8. What product line had the largest VAT?
 
 SELECT * FROM walmart;
 
 WITH  L_VAT AS ( 
SELECT DISTINCT(Product_line), SUM(VAT) AS "Largest_VAT" FROM WALMART
GROUP BY PRODUCT_LINE)
SELECT * FROM L_VAT 
WHERE Largest_VAT=(SELECT MAX(Largest_VAT) FROM L_VAT);
 
 
 -- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
 select * from walmart;
 
 
 
 
 select product_line, count(quantity) as total_sales,
case  
	when count(quantity) > avg(quantity) then "Good"
    else "bad" 
    end "type"
    from walmart
group by product_line
order by total_sales desc;
 
 
 -- 10. Which branch sold more products than average product sold?
 
 with avg_b as (
select branch ,sum( quantity) as "more_products" from walmart
group by branch)
 
SELECT * FROM AVG_B WHERE more_products>(
SELECT AVG(more_products) AS products FROM AVG_B);
 
 -- 11. What is the most common product line by gender?

select * from walmart;
 WITH MALE AS (
SELECT GENDER,Product_line, COUNT(PRODUCT_LINE) AS PRODUCTS FROM walmart
WHERE GENDER="MALE"
GROUP BY Product_line
)
SELECT * FROM MALE 
WHERE PRODUCTS=(SELECT MAX(PRODUCTS) FROM MALE);
 
 
WITH FEMALE AS (
SELECT GENDER, Product_line, COUNT(PRODUCT_LINE) AS PRODUCTS FROM walmart
WHERE GENDER="FEMALE"
GROUP BY Product_line
)
SELECT * FROM FEMALE 
WHERE PRODUCTS=(SELECT MAX(PRODUCTS) FROM FEMALE);
 
 
 
 
 -- 12. What is the average rating of each product line?
 
      SELECT Product_line, AVG(Rating) AS "Average_rating" FROM WALMART
	  GROUP BY Product_line
      ORDER BY AVG(Rating);
 
 
 
                                                                        /**Sales **/
 -- 1. Number of sales made in each time of the day per weekday 
      select * from walmart;
 

     SELECT Time_of_day,COUNT(Time_of_day) FROM walmart
     WHERE Day_name !="SATURDAY" AND Day_name !="SUNDAY"
     GROUP BY Time_of_day;
     
 
 -- 2. Which of the customer types brings the most revenue?
 
 WITH REVENUE AS(
SELECT Customer_type ,SUM(Total) AS "Most_revenue" FROM WALMART
GROUP BY Customer_type
ORDER BY SUM(Total) DESC)
SELECT * FROM REVENUE 
WHERE MOST_REVENUE= (SELECT MAX(MOST_REVENUE) FROM REVENUE);
 
 
 
 -- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
 
 WITH VAT_C AS (
SELECT City, SUM(VAT) AS "Largest_VAT_CITY" FROM WALMART
GROUP BY City
ORDER BY SUM(VAT) DESC	)
SELECT * FROM VAT_C
WHERE Largest_VAT_CITY=(SELECT MAX( Largest_VAT_CITY) FROM VAT_C);
 
 
 -- 4. Which customer type pays the most in VAT?
 
 WITH VAT AS (
SELECT Customer_type,SUM(VAT) AS "Most_VAT_paying_customer_type" FROM WALMART
GROUP BY Customer_type 
ORDER BY SUM(VAT) DESC)
SELECT * FROM VAT
WHERE Most_VAT_paying_customer_type= (SELECT MAX( Most_VAT_paying_customer_type) FROM VAT);
 
 
 
 
                                                                         /** Customer **/
 -- 1. How many unique customer types does the data have?
 
 SELECT COUNT(DISTINCT(Customer_type))	AS "unique customer_types" FROM WALMART;

 
 
 -- 2. How many unique payment methods does the data have?
 SELECT COUNT(DISTINCT(Payment)) AS "Unique_payment_methods" FROM WALMART;


 
 
 -- 3. What is the most common customer type?
 
 WITH CUSTOMER AS (
SELECT Customer_type,COUNT(*) AS NO_OF_CUSTOMERS FROM WALMART
GROUP BY Customer_type 
Order BY COUNT(Customer_type) DESC)
SELECT * FROM CUSTOMER 
WHERE  NO_OF_CUSTOMERS=(SELECT MAX( NO_OF_CUSTOMERS) FROM CUSTOMER);
 
 
 
 
 -- 4. Which customer type buys the most?
 
 WITH MOST AS (
SELECT Customer_type , COUNT(Invoice_id) AS  NUMB FROM WALMART
GROUP BY Customer_type
ORDER BY COUNT(Invoice_id) DESC)
SELECT * FROM MOST 
WHERE NUMB=(SELECT MAX(NUMB) FROM MOST);
 
 
 
 -- 5. What is the gender of most of the customers?
 

 WITH  MOST1  AS(
SELECT Gender, COUNT(Gender) AS MOST	FROM WALMART
GROUP BY Gender
)
SELECT * FROM MOST1
WHERE MOST=(SELECT MAX(MOST) FROM MOST1);
 
 
 
 
 
 -- 6. What is the gender distribution per branch? 
 
SELECT branch,gender,count(gender) AS "Gender_distribution"FROM WALMART
GROUP BY BRANCH ,gender
order by branch;
 
 
 
 
 
 -- 7. Which time of the day do customers give most ratings?
 
 WITH RATINGS AS ( 
SELECT Time_of_day , COUNT(Rating) AS"Count_of_Ratings" FROM WALMART
GROUP BY Time_of_day )
SELECT * FROM RATINGS WHERE Count_of_Ratings=(SELECT MAX(Count_of_Ratings) FROM RATINGS);
 

 
 
  -- 8. Which time of the day do customers give most ratings per branch?
  
  
with branches as (select branch, time_of_day,count(rating)  ratingcounts from walmart 
group by 1,2 order by 1,2 desc)
,ranked as(select *,dense_rank() over(partition by branch order by ratingcounts desc) as ranks from branches)
select branch,time_of_day,ratingcounts from ranked where ranks=1;

 
 
 -- 9. Which day of the week has the best avg ratings?
 
 select * from walmart;
 
WITH avg_ratings AS (
    SELECT day_name, AVG(Rating) AS avg_rating
    FROM walmart
    GROUP BY day_name
),
max_avg_rating AS (
    SELECT MAX(avg_rating) AS max_avg FROM avg_ratings
)
SELECT day_name, avg_rating
FROM avg_ratings
WHERE avg_rating = (SELECT max_avg FROM max_avg_rating);
  
 
-- 10. Which day of the week has the best average ratings per branch?


WITH avg_ratings AS (
    SELECT day_name,branch, AVG(Rating) AS avg_rating
    FROM walmart
    GROUP BY day_name,branch
),
max_avg_rating AS (
    SELECT MAX(avg_rating) AS max_avg FROM avg_ratings
)
SELECT day_name,branch , avg_rating
FROM avg_ratings
WHERE avg_rating = (SELECT max_avg FROM max_avg_rating);



      

                
                
                



