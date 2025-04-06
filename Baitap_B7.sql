--Ex 01
select Name
from Students
where marks >75
order by right(name,3), ID
--Ex 02
select user_id,
concat(upper(left(name,1)),lower(right(name,length(name)-1))) as name
from Users
--Ex 03
SELECT
manufacturer,
concat('$',round(sum(total_sales)/1000000,0),' million') as sale
FROM pharmacy_sales
group by manufacturer
order by round(sum(total_sales),0) DESC,manufacturer
--Ex 04
SELECT 
extract(month from submit_date) as mth,
product_id as product,
round(avg(stars),2) as avg_starts
FROM reviews
group by extract(month from submit_date),product_id
order by extract(month from submit_date), product_id
--Ex 05
SELECT 
sender_id,
count(message_id) as count_messages
FROM messages
where extract(month from sent_date)=8 and extract(year from sent_date)=2022
group by sender_id
order by count(message_id) DESC
limit 2
--Ex 06
select 
tweet_id
from Tweets
where length(content)>15 
--Ex 07
select
activity_date as day,
count(distinct user_id) as active_users
from Activity
group by activity_date
having activity_date >='2019-06-27' and activity_date <='2019-07-27'
--Ex 08
select 
count(employee_id) as number_employee
from employees
where extract(month from joining_date) between 1 and 7
and extract(year from joining_date)=2022
--Ex 09
select 
position('a' in first_name) as postision
from worker
where first_name='Amitah'
--Ex 10
select 
substring(title,length(winery)+2,4)
from winemag_p2
where country='Macedonia'
