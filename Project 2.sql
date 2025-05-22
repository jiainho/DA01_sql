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

--select * from strategic-grove-459715-i9.12345.vw_ecommerce_analyst
--- month, year, Product_category, TPV, TPO, Total_cost, Total_profit, Profit_to_cost_ratio, Revenue_growth --26 null , Order_growth --26

select * FROM strategic-grove-459715-i9.12345.vw_ecommerce_analyst  -- 1700 BANG GHI
WHERE Order_growth IS NULL

/* Bước 1 - Khám phá & làm sạch dữ liệu
- Chúng ta đang quan tâm đến trường nào?
- Check null
- Chuyển đổi kiểu dữ liệu
- Số tiền và số lượng > 0
- Check dup */
with table_convert as (
select 
CAST(PARSE_DATE('%Y-%m', month) AS TIMESTAMP) AS month, 
year, 
Product_category, 
cast(TPV as numeric) as TPV,
cast(TPO as int) as TPO,
cast(Total_cost as numeric) as Total_numeric,
cast(Total_profit as numeric) as Total_profit,
cast(Profit_to_cost_ratio as numeric) as Profit_to_cost_ratio,
Revenue_growth,
Order_growth
from strategic-grove-459715-i9.12345.vw_ecommerce_analyst
WHERE Order_growth <>''
and cast(TPO as int)>0
and cast(TPV as numeric) >0)

,table_main as(
  select * from(
select *,
row_number() over(partition by month,year, Product_category, TPO, TPV order by month ) as stt
from table_convert) as t
where stt=1)

--select * from table_main

----Bước 2:
-- Tìm ngày mua hàng đầu tiên của mỗi KH => cohort_date
-- Tìm index=tháng ( ngày mua hàng - ngày đầu tiên) + 1
-- Count số lượng KH hoặc tổng doanh thu tại mỗi cohort_date và index tương ứng
-- Pivot table

--- begin analyst 

--select * from table_main
, table_index as(
  select
  Product_category,
  TPV,
  FORMAT_DATE('%Y-%m', DATE(first_purchase_date)) AS cohort_date,
  month,
  (extract('year' from month)-extract('year' from first_purchase_date))*12
	+(extract('month' from month)-extract('month' from first_purchase_date))+1 as index
  from(
    select Product_category,
TPV,
MIN(month) over(PARTITION BY Product_category) as first_purchase_date ,
month
from table_main t
) a)

,xxx as(
SELECT 
cohort_date,
index,
count(distinct Product_category) as cnt,
  sum(TPV) as revenue
from table_index
group by cohort_date, index)

,customer_cohort as (
select 
cohort_date,
sum(case when index=1 then cnt else 0 end ) as m1,
sum(case when index=2 then cnt else 0 end ) as m2,
sum(case when index=3 then cnt else 0 end ) as m3,
sum(case when index=4 then cnt else 0 end ) as m4,
sum(case when index=5 then cnt else 0 end ) as m5,
sum(case when index=6 then cnt else 0 end ) as m6,
sum(case when index=7then cnt else 0 end ) as m7,
sum(case when index=8 then cnt else 0 end ) as m8,
sum(case when index=9then cnt else 0 end ) as m9,
sum(case when index=10 then cnt else 0 end ) as m10,
sum(case when index=11 then cnt else 0 end ) as m11,
sum(case when index=12 then cnt else 0 end ) as m12,
sum(case when index=13 then cnt else 0 end ) as m13
from xxx
group by cohort_date
order by cohort_date)

select
cohort_date,
(100-round(100.00* m1/m1,2))||'%'  as m1,
(100-round(100.00* m2/m1,2))|| '%'  as m2,
(100-round(100.00* m3/m1,2)) || '%'  as m3,
round(100.00* m4/m1,2) || '%'  as m4,
round(100.00* m5/m1,2) || '%'  as m5,
round(100.00* m6/m1,2) || '%'  as m6,
round(100.00* m7/m1,2) || '%'  as m7,
round(100.00* m8/m1,2) || '%'  as m8,
round(100.00* m9/m1,2) || '%'  as m9,
round(100.00* m10/m1,2) || '%'  as m10,
round(100.00* m11/m1,2) || '%'  as m11,
round(100.00* m12/m1,2) || '%'  as m12,
round(100.00* m13/m1,2) || '%'  as m13
from customer_cohort

Syntax error: Missing whitespace between literal and alias at [70:22] !!


