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
-- EX 05

-- EX 06

-- EX 07

-- EX 08
