--ex 1
select name from city
where population >120000 and countrycode ='USA'
--ex 2
select * from city
where COUNTRYCODE = 'JPN'
--ex 3
select CITY, STATE from STATION
--ex 4
select CITY from STATION
where CITY like 'a%' or CITY like 'e%' or CITY like 'i%' or CITY like 'o%' or CITY like 'u%'
--ex 5
select distinct CITY from STATION
where CITY like '%a' or CITY like '%e' or CITY like '%i' or CITY like '%o' or CITY like '%u'
--ex 6
select  distinct  CITY from STATION
where CITY not like 'a%' and CITY not like 'e%' and CITY not like 'i%' and CITY not like 'o%' and CITY not like 'u%'
--ex 7
select name from Employee
ORDER BY name ASC
--ex 8
select name from Employee
where salary>2000 and months<10
order by employee_id
--ex 9
select product_id from products
where low_fats = 'Y' and recyclable = 'Y'
--ex 10
select name from Customer
where referee_id != 2 or referee_id is null
--ex 11
select name, population, area from World
where area >= 3000000 or population >=25000000
--ex 12
select distinct author_id as id from Views
where  author_id = viewer_id
order by author_id ASC
--ex 13
SELECT part, assembly_step FROM parts_assembly
where finish_date is null
--ex 14
select * from lyft_drivers
where yearly_salary <=30000 or yearly_salary >=70000
--ex 15
select * from uber_advertising
where money_spent >100000 and year = 2019
