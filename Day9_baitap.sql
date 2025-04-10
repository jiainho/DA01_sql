--ex 01
SELECT 
sum(CASE
  WHEN DEVICE_TYPE = 'laptop' THEN 1 ELSE 0
END) AS laptop_views,
sum(CASE
  WHEN DEVICE_TYPE IN ('phone','tablet') THEN 1 ELSE 0
END) AS mobile_views
FROM viewership

--ex 02
select *,
case
when (x<z and y<z and x+y>z) or (x<y and z<y and x+z>y)  or (y<x and z<x and y+z>x)  then 'Yes' else 'No'
end as triangle
from Triangle
  
--ex 03 ---> CHUA CHAY DUOC
SELECT
ROUND(CAST(SUM(CASE
WHEN call_category ='n/a' THEN 1 ELSE 0
END)/COUNT(call_category)*100 AS DECIMAL),1) AS uncategorised_call_pct
FROM callers

--ex 04
SELECT name 
from Customer
where referee_id <>2 or referee_id is null
--ex 05
select 
survived,
sum(case
when pclass = 1 then 1 else 0
end) as first_class,

sum(case
when pclass = 2 then 1 else 0
end) as second_class,

sum(case
when pclass = 3 then 1 else 0
end) as third_class

from titanic
group by survived
