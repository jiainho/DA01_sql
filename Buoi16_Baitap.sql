-- EX 01
Select round(avg(order_date = customer_pref_delivery_date)*100, 2) as immediate_percentage
from Delivery
where (customer_id, order_date) in (
  Select customer_id, min(order_date) 
  from Delivery
  group by customer_id
);
-- EX 02 ??
select
round(count(distinct player_id) / (select count(distinct player_id) from activity), 2) as fraction
from activity
where (player_id, DATE_SUB(event_date, INTERVAL 1 DAY)) 
IN (
    select player_id, MIN(event_date) AS first_login FROM activity
    Group by player_id
)
-- EX 03
select id,
case
when id % 2= 0 then lag(student) over(order by id)
else coalesce(lead(student) over(order by id), student)
end as student
from seat
-- EX 04
SELECT visited_on, amount, average_amount 
FROM (
    SELECT DISTINCT visited_on, 
    SUM(amount) OVER (ORDER BY visited_on RANGE BETWEEN INTERVAL 6 DAY PRECEDING AND CURRENT ROW) AS amount,
    ROUND(SUM(amount) OVER (ORDER BY visited_on RANGE BETWEEN INTERVAL 6 DAY PRECEDING AND CURRENT ROW)/7,2) AS average_amount

FROM Customer) as whole_totals
WHERE DATEDIFF(visited_on, (SELECT MIN(visited_on) FROM Customer)) >= 6
-- EX 05  >>
SELECT ROUND(SUM(TIV_2016),2) AS TIV_2016
FROM
(SELECT *,
COUNT(*) OVER(PARTITION BY TIV_2015) AS CNT1,
COUNT(*) OVER(PARTITION BY LAT, LON) AS CNT2
FROM INSURANCE
) AS TBL
WHERE CNT1 > =2 AND CNT2 =1
-- EX 06
SELECT Department, Employee, Salary
FROM(
    SELECT D.name AS Department, E.name AS Employee, E.salary AS Salary,
    DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS d_rank
    FROM Employee E INNER JOIN Department D ON E.departmentId = D.id
) T
WHERE d_rank <= 3
-- EX 07
WITH CumulativeSum AS (
    SELECT person_name, SUM(weight) OVER (ORDER BY turn) AS cumulative_sum
    FROM Queue
)
SELECT person_name
FROM CumulativeSum
WHERE cumulative_sum <= 1000
ORDER BY cumulative_sum DESC
LIMIT 1;
-- EX 08
SELECT P.product_id, COALESCE(x.new_price,10) as price
FROM (SELECT *,
RANK() OVER (PARTITION BY product_id ORDER BY change_date DESC) as drank
FROM Products
WHERE change_date <= "2019-08-16") x
RIGHT JOIN Products P on P.product_id = x.product_id
WHERE x.drank=1 or x.drank is null
GROUP BY P.product_id
