--EX 1
  select count(distinct company_id) as duplicate_companies
  from (SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description) as aa
  where job_count>1
--EX 2
with abc as(

select category,product, sum(spend) as total_spend,
RANK() over (
  PARTITION BY category
  ORDER BY SUM(spend) DESC) AS ranking
from product_spend
where extract(year from transaction_date)=2022
group by category, product
)

select category, product, total_spend
from abc 
where ranking <=2
order by category,total_spend desc 
--EX 3
with abc as(
select policy_holder_id,
count(policy_holder_id)
from callers
group by policy_holder_id
having count(policy_holder_id)>=3
)
select count(policy_holder_id) as policy_holder_count
from abc 

--EX 4
SELECT a.page_id
FROM pages as a 
LEFT JOIN page_likes as b 
  ON a.page_id = b.page_id
WHERE b.page_id IS NULL;
--EX 5 -- chưa hiểu

--EX 6
SELECT LEFT(trans_date, 7) AS month, country, 
COUNT(id) AS trans_count,
SUM(state = 'approved') AS approved_count,
SUM(amount) AS trans_total_amount,
SUM((state = 'approved') * amount) AS approved_total_amount
FROM Transactions
GROUP BY month, country
--EX 7
select product_id, year as first_year, quantity, price 
from Sales 
where(product_id, year) in
(select product_id, min(year)
from Sales
group by product_id)
--EX 8
select customer_id 
from Customer
group by customer_id
having count(distinct product_key) =(select 
count(product_key) from product)
--EX 9
select employee_id
from employees
where salary<30000 
and manager_id not in (select employee_id from employees)
--EX 10
select count(distinct company_id) as duplicate_companies
  from (SELECT 
   company_id, 
title, 
description, 
 COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description) as aa
  where job_count>1
--EX 11
(SELECT name AS results
FROM MovieRating JOIN Users USING(user_id)
GROUP BY name
ORDER BY COUNT(*) DESC, name
LIMIT 1)

UNION ALL

(SELECT title AS results
FROM MovieRating JOIN Movies USING(movie_id)
WHERE EXTRACT(YEAR_MONTH FROM created_at) = 202002
GROUP BY title
ORDER BY AVG(rating) DESC, title
LIMIT 1)
--EX 12
select id,count(*) as num
from (
select requester_id as id
from RequestAccepted

UNION ALL

select accepter_id as id
from RequestAccepted
) as friend_count
group by id
order by num desc
limit 1
