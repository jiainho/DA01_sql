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

==> Insight đáp án:
/*--> Insight: 
    - Nhìn chung số lượng người mua hàng và đơn hàng tiêu thụ đã hoàn thành tăng dần theo mỗi tháng và năm   
    - Giai đoạn 2019-tháng 1 2022: người mua hàng có xu hướng mua sắm nhiều hơn vào ba tháng cuối năm (10-12) và tháng 1 năm kế tiếp do nhu cầu mua sắm cuối/đầu năm tăng 
           và nhiều chương trình khuyến mãi/giảm giá cuối năm           
    - Giai đoạn bốn tháng đầu năm 2022: ghi nhận tỷ lệ lượng người mua tăng mạnh so với ba tháng cuối năm 2021, khả năng do TheLook triển khai chương trình khuyến mãi mới nhằm 
      kích cầu mua sắm các tháng đầu năm
    - Tháng 7 2021 ghi nhận lượng mua hàng tăng bất thường, trái ngược với lượng mua giảm sút so với cùng kì năm 2020, có thể do TheLook triển khai campaign đặc biệt cải thiện tình hình 
      doanh số cho riêng tháng 7.
*/

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

/*--> Insight: - Giai đoạn năm 2019 do số lượng người dùng ít khiến giá trị đơn hàng trung bình qua các tháng có tỷ lệ biến động cao.
               - Giai đoạn từ cuối năm 2019 lượng người dùng ổn định trên 400 và nhìn chung tiếp tục tăng qua các tháng, giá trị đơn hàng trung bình qua các tháng ổn định ở mức ~80-90
 */

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

/*  
  --> Insight: trong giai đoạn Từ 1/2019-4/2022
      - Giới tính Female: lớn tuổi nhất là 70 tuổi (525 người người dùng); nhỏ tuổi nhất là 12 tuổi (569 người dùng)
      - Giới tính Male: lớn tuổi nhất là 70 tuổi (529 người người dùng); nhỏ tuổi nhất là 12 tuổi (546 người dùng)
*/	
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
___SAI CODE______________________________________________________________
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
_________________________________________________________________________
--> Code sửa
/* 
2) Cohort chart
*/
With a as
(Select user_id, amount, FORMAT_DATE('%Y-%m', first_purchase_date) as cohort_month,
created_at,
(Extract(year from created_at) - extract(year from first_purchase_date))*12 
  + Extract(MONTH from created_at) - extract(MONTH from first_purchase_date) +1
  as index
from 
(
Select user_id, 
round(sale_price,2) as amount,
Min(created_at) OVER (PARTITION BY user_id) as first_purchase_date,
created_at
from bigquery-public-data.thelook_ecommerce.order_items 
) as b),
cohort_data as
(
Select cohort_month, 
index,
COUNT(DISTINCT user_id) as user_count,
round(SUM(amount),2) as revenue
from a
Group by cohort_month, index
ORDER BY INDEX
),
--CUSTOMER COHORT-- 
Customer_cohort as
(
Select 
cohort_month,
Sum(case when index=1 then user_count else 0 end) as m1,
Sum(case when index=2 then user_count else 0 end) as m2,
Sum(case when index=3 then user_count else 0 end) as m3,
Sum(case when index=4 then user_count else 0 end) as m4
from cohort_data
Group by cohort_month
Order by cohort_month
),
--RETENTION COHORT--
retention_cohort as
(
Select cohort_month,
round(100.00* m1/m1,2) || '%' as m1,
round(100.00* m2/m1,2) || '%' as m2,
round(100.00* m3/m1,2) || '%' as m3,
round(100.00* m4/m1,2) || '%' as m4
from customer_cohort
)
--CHURN COHORT--
Select cohort_month,
(100.00 - round(100.00* m1/m1,2)) || '%' as m1,
(100.00 - round(100.00* m2/m1,2)) || '%' as m2,
(100.00 - round(100.00* m3/m1,2)) || '%' as m3,
(100.00 - round(100.00* m4/m1,2))|| '%' as m4
from customer_cohort
	
--> Chart cohort:
https://docs.google.com/spreadsheets/d/1KT6kU-WSc6_qrohmylYGuGhpAznP0vwb/edit?usp=sharing&ouid=113831551563412238237&rtpof=true&sd=true

--> Insight - Bài sửa
/*
Nhìn chung hằng tháng TheLook ghi nhận số lượng người dùng mới tăng dần đều, thể hiện chiến dịch quảng cáo tiếp cận người dùng
mới có hiệu quả.
Tuy nhiên trong giai đoạn 4 tháng đầu tính từ lần mua hàng/sử dụng trang thương mại điện tử TheLook, tỷ lệ người dùng cũ
quay lại sử dụng trong tháng kế tiếp khá thấp: dao động dưới 10% trong giai đoạn từ 2019-01 đến 2023-07 và tăng lên mức 
trên 10% trong những tháng còn lại của năm 2023, trong đó cao nhất là tháng đầu tiên sau 2023-10 với 18.28%.
 --> Tỷ lệ khách hàng trung thành thấp, TheLook nên xem xét cách quảng bá để thiếp lập và tiếp cận nhóm khách hàng trung thành
nhằm tăng doanh thu từ nhóm này và tiết kiệm các chi phí marketing
