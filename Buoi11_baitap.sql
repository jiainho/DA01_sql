--EX 1
SELECT a.Continent, FLOOR(avg(b.population))
FROM Country as a
join city as b
on a.Code=b.CountryCode
group by a.Continent
order by round(avg(b.population),0)
--EX 2
SELECT round(count(b.signup_action)::decimal/count(distinct a.email_id),2) as confirm_rate
FROM emails as a
left join texts as b 
on a.email_id=b.email_id
and b.signup_action = 'Confirmed';
--EX 3
SELECT 
b.age_bucket, 
ROUND(100.0 *SUM(a.time_spent) FILTER (WHERE a.activity_type = 'send')/SUM(a.time_spent),2) AS send_perc, 
ROUND(100.0 *SUM(a.time_spent) FILTER (WHERE a.activity_type = 'open')/SUM(a.time_spent),2) AS open_perc
FROM activities as a 
INNER JOIN age_breakdown as b 
ON a.user_id = b.user_id 
WHERE a.activity_type IN ('send', 'open') 
GROUP BY b.age_bucket;
--EX 4
select a.customer_id
from customer_contracts as a 
join products as b 
on a.product_id=b.product_id
group by a.customer_id
HAVING 
COUNT(DISTINCT product_category) =
(select COUNT(DISTINCT product_category) from products)
--EX 5
select  tb2.employee_id, tb2.name, 
count(tb1.reports_to) as reports_count, round(avg(tb1.age),0) as average_age 
from employees as tb1
join employees as tb2
on tb2.employee_id=tb1.reports_to
group by tb2.name, tb2.employee_id
--EX 6
select a.product_name, sum(b.unit) as unit
from Products as a
join Orders as b
on a.product_id=b.product_id
where b.order_date >'2020-02-01' and b.order_date < '2020-03-01'
group by a.product_name
having sum(b.unit) >= 100
--EX 7
SELECT a.page_id
FROM pages as a 
LEFT JOIN page_likes as b 
ON a.page_id = b.page_id
WHERE b.page_id IS NULL;
