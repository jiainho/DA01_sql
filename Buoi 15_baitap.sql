--EX 01
SELECT extract(year from transaction_date) as year, product_id, spend as curr_year_spend,
lag(spend) over(partition by product_id order by transaction_date) as prev_year_spend,
round((spend-lag(spend) over(partition by product_id order by transaction_date))/lag(spend) over(partition by product_id order by transaction_date)*100,2) as yoy_rate
FROM user_transactions;
--EX 02
with card_launch as(
SELECT
card_name,issued_amount, make_date(issue_year, issue_month,1) as issue_date,
first_value(make_date(issue_year, issue_month,1)) over(partition by card_name order by make_date(issue_year, issue_month,1) ) as launch_date
from monthly_cards_issued
)
SELECT card_name, issued_amount
from card_launch
where issue_date=launch_date
order by issued_amount DESC
--EX 03
with abc as(
SELECT *,
row_number() over(partition by user_id order by transaction_date) as rank

FROM transactions)
select user_id,	spend,	transaction_date
from abc 
where rank=3
--EX 04
with abc as(
SELECT 
transaction_date, user_id,
product_id, 
    RANK() OVER (
      PARTITION BY user_id 
      ORDER BY transaction_date DESC) AS transaction_rank 
  FROM user_transactions)

select transaction_date, user_id,
count(product_id) as purchase_count
from abc 
where transaction_rank=1
group by transaction_date, user_id
order by transaction_date
--EX 05
SELECT 
user_id,	tweet_date,
round(avg(tweet_count) over(partition by user_id order by tweet_date
 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)as rolling_avg_3d
FROM tweets;
--EX 06
with abc as(
SELECT *,
lag(transaction_timestamp) over(partition by merchant_id,	credit_card_id, amount order by transaction_timestamp) as tran2,
extract(EPOCH from transaction_timestamp-lag(transaction_timestamp) over(partition by merchant_id,	credit_card_id, amount order by transaction_timestamp))/60 as diff,
lag(amount) over(partition by merchant_id,	credit_card_id, amount order by transaction_timestamp) as amount2
FROM transactions)

select 
count(transaction_id) as payment_count
from abc 
where amount2=amount and diff <= 10
--EX 07
WITH abc AS (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)

SELECT 
  category, 
  product, 
  total_spend 
FROM abc
WHERE ranking <= 2 
ORDER BY category, ranking;
--EX 08
with abc as(
select a.artist_name,
DENSE_RANK() over(order by count(global.song_id) desc) as artist_rank
from global_song_rank as global
inner join songs as song on global.song_id= song.song_id
inner join artists as a on a.artist_id= song.artist_id
where global.rank<=10
group by a.artist_name)

select artist_name,artist_rank
from abc
where artist_rank<=5

