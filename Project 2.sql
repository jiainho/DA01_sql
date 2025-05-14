--II. Ad-hoc tasks
--1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng

select  --month_year ( yyyy-mm) , total_user, total_order
FORMAT_TIMESTAMP('%Y-%m', created_at) as month_year,
count(distinct user_id) as total_user,
count(distinct order_id) as total_order
from bigquery-public-data.thelook_ecommerce.orders
where created_at between '2019-01-01' and '2022-04-30'
and status = 'Complete'
group by 1
order by 1
-- Insight:
total_user, total_order có xu hướng tăng từ 2019 - 2022

--2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
select 
FORMAT_TIMESTAMP('%Y-%m', created_at) as month_year,
count(distinct user_id) as distinct_user,
round(sum(sale_price)/ count(order_id),2) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-04-30'
and status = 'Complete'
group by 1
order by 1
-- Insight:
distinct_user tăng theo thời gian, nhưng average_order_value xu hương tương tự theo thời gian


--Câu 3
WITH M_youngest AS (
  SELECT 
    first_name, last_name, gender, age, 
    'youngest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
  AND gender = 'M'
    AND age = (SELECT MIN(age) 
               FROM bigquery-public-data.thelook_ecommerce.users
               WHERE gender = users.gender)
),
M_oldest AS (
  SELECT 
    first_name, last_name, gender, age, 
    'oldest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
    AND gender = 'M'
    AND age = (SELECT MAX(age) 
               FROM bigquery-public-data.thelook_ecommerce.users 
               WHERE gender = users.gender)
),

F_youngest AS (
  SELECT 
    first_name, last_name, gender, age, 
    'youngest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
  AND gender = 'F'
    AND age = (SELECT MIN(age) 
               FROM bigquery-public-data.thelook_ecommerce.users
               WHERE gender = users.gender)
),
F_oldest AS (
  SELECT 
    first_name, last_name, gender, age, 
    'oldest' AS tag
  FROM bigquery-public-data.thelook_ecommerce.users
  WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
    AND gender = 'F'
    AND age = (SELECT MAX(age) 
               FROM bigquery-public-data.thelook_ecommerce.users 
               WHERE gender = users.gender)
)
SELECT * FROM F_oldest
UNION all
SELECT * FROM F_youngest
UNION all
SELECT * FROM M_oldest
UNION all
SELECT * FROM M_youngest


-- 4
with product_sales as(
select 
FORMAT_TIMESTAMP('%Y-%m', a.created_at) as month_year,
a.product_id, 
b.name as product_name,

sum(a.sale_price) as sales,
sum(b.cost) as cost,
sum(a.sale_price)-sum(b.cost) as profit

from bigquery-public-data.thelook_ecommerce.products as b
join bigquery-public-data.thelook_ecommerce.order_items as a
on a.id=b.id
where a.created_at between '2019-01-01' and '2022-04-30'
and a.status = 'Complete'
group by 1,2,3
order by 1),

ranked_products as(
select *,
 dense_rank() over(partition by month_year order by profit DESC) as rank_per_month
from product_sales)

select * from ranked_products
where rank_per_month <=5
order by month_year

-- 5
select 
FORMAT_TIMESTAMP('%Y-%m-%d', a.created_at) as month_year_day,
b.category as product_categories,
sum(a.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.products as b
join bigquery-public-data.thelook_ecommerce.order_items as a
on a.id=b.id
where a.created_at between '2022-01-15' and '2022-04-15'
and a.status = 'Complete'
group by 1, 2
order by 1


select * from bigquery-public-data.thelook_ecommerce.order_items
--id, order_id, user_id, product_id, inventory_item_id, status (complete,canelled, processing,...), created_at. shipped_at, delivered_at, returned_at, sale_price
SELECT * FROM bigquery-public-data.thelook_ecommerce.orders
-- order_id, user_id, status, gender, created_at, num_of_item
SELECT * FROM bigquery-public-data.thelook_ecommerce.products
-- id, cost, category,name, brand, retail_price, department, sku, distribution_center_id



create or replace view vw_ecommerce_analyst AS
with abc as(
select
FORMAT_TIMESTAMP('%Y-%m', c.created_at) as Month,
Extract(Year from c.created_at) as Year,
b.category as Product_category,
sum(a.sale_price) as TPV,
count(distinct a.order_id) as TPO,

sum(b.cost) as Total_cost,
sum(a.sale_price)-sum(b.cost) as Total_profit,
(sum(a.sale_price)-sum(b.cost))/sum(b.cost) as Profit_to_cost_ratio

from bigquery-public-data.thelook_ecommerce.products as b
join bigquery-public-data.thelook_ecommerce.order_items as a on a.id=b.id
join bigquery-public-data.thelook_ecommerce.orders as c on a.order_id=c.order_id
--where a.status = 'Complete'
group by 1,2,3
order by 1),

def as(
select *,
ROUND(100*(TPV-lag(TPV) over(partition by Product_category order by month))/lag(TPV) over(partition by Product_category order by month),2) || '%' as Revenue_growth, --doanh thu tháng sau-doanh thu tháng trước)/doanh thu tháng trước
ROUND(100*(TPO-lag(TPO) over(partition by Product_category order by month))/lag(TPO) over(partition by Product_category order by month),2) || '%' as Order_growth, --số đơn hàng tháng sau - số đơn hàng tháng trước)/số đơn tháng trước
from abc)

select * from def

