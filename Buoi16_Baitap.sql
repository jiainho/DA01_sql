-- EX 01
Select round(avg(order_date = customer_pref_delivery_date)*100, 2) as immediate_percentage
from Delivery
where (customer_id, order_date) in (
  Select customer_id, min(order_date) 
  from Delivery
  group by customer_id
);
-- EX 02

-- EX 03

-- EX 04

-- EX 05

-- EX 06

-- EX 07

-- EX 08
