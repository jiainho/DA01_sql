Mid-term
--EX 1
select distinct replacement_cost from film
order by replacement_cost 
limit 1
--EX 2
  select 
sum(case
when replacement_cost >=9.99 and replacement_cost<=19.99 then 1 else 0
end) as low
from film
--EX 3
select a.title, a.length, c.name
from film as a
join film_category as b on a.film_id=b.film_id
join category as c on b.category_id=c.category_id
where c.name = 'Drama' or c.name ='Sports'
order by a.length desc
limit 1
--EX 4
select c.name as category, count(a.title)||' titles' as tilte
from film as a
join film_category as b on a.film_id=b.film_id
join category as c on b.category_id=c.category_id
group by c.name
order by count(a.title) desc
limit 1
--EX 5
select a.first_name, a.last_name, count(b.film_id)|| ' movies' as no_film
from actor as a
join film_actor as b on a.actor_id=b.actor_id
group by a.first_name, a.last_name
order by count(b.film_id) desc
limit 1
--EX 6
select count(b.address_id)
from address as b
left join customer as a
on a.address_id=b.address_id
where a.address_id is null
--EX 7
select a.city, sum(d.amount)
from city as a
join address as b on  a.city_id=b.city_id
join customer as c on c.address_id=b.address_id
join payment as d on d.customer_id=c.customer_id
group by a.city
order by sum(d.amount) desc
limit 1
--EX 8
select e.country,a.city, sum(d.amount)as sum_amount
from city as a
join address as b on  a.city_id=b.city_id
join customer as c on c.address_id=b.address_id
join payment as d on d.customer_id=c.customer_id
join country as e on e.country_id=a.country_id
group by a.city, e.country
order by sum(d.amount) 
limit 1
