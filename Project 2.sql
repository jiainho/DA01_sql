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
