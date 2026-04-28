-- ==========================================================
-- STEP 0: RENAME ORIGINAL TABLES FOR BETTER READABILITY
-- Removing 'olist_' prefix and cleaning up names
-- ==========================================================

ALTER TABLE olist_customers_dataset RENAME TO customers;
ALTER TABLE olist_order_items_dataset RENAME TO order_items;
ALTER TABLE olist_order_payments_dataset RENAME TO order_payments;
ALTER TABLE olist_order_reviews_dataset RENAME TO order_reviews;
ALTER TABLE olist_orders_dataset RENAME TO orders;
ALTER TABLE olist_products_dataset RENAME TO products;
ALTER TABLE olist_sellers_dataset RENAME TO sellers;
ALTER TABLE product_category_name_translation RENAME TO translation;


-- ==========================================================
-- STEP 1: DATA PREPARATION & DENORMALIZATION
-- Combining 8 raw tables into 2 analytical datasets
-- ==========================================================

create table order_details_1 as
select *
from order_items oi
full join sellers s
	using (seller_id)
full join products
	using (product_id)
full join translation
	using (product_category)
full join order_payments op
	using (order_id)
full join orders o
	using (order_id)
full join customers
	using (customer_id)
full join order_reviews
	using (order_id);


create table payments_aggregated as
select
	order_id,
	max(payment_installments) as payment_installments,
	sum(payment_value) as total_payment
from order_details_1
group by order_id;

create table reviews_aggregated as
select
	order_id,
	avg(review_score) as review_score
from order_reviews
group by order_id;

create table items_aggregated as
select
	order_id,
	count(order_item_id) as basket_size,
	sum(price) as items_total_price,
	avg(price) as price_per_item,
	sum(freight_value) as freight_total
from order_items
group by order_id;

create table orders_aggregated as
select
	order_id,
	max(order_delivered_customer_date - order_approved_at) as delivery_days,
	max(greatest(interval '0', order_delivered_customer_date - order_estimated_delivery_date)) filter(where order_delivered_customer_date is not null) as delivery_delay
from orders
group by order_id;


-- ORDERS DETAILED table
create table orders_detailed as
select *
from orders
left join customers
	using (customer_id)
left join items_aggregated
	using (order_id)
left join payments_aggregated
	using (order_id)
left join orders_aggregated
	using (order_id)
left join reviews_aggregated
	using (order_id);


-- ITEMS DETAILED table
create table items_detailed as
select *
from order_items
left join orders_partial
	using (order_id)
left join customers
	using (customer_id)
left join products
	using (product_id)
left join sellers
	using (seller_id)
left join translation
	using (product_category);

alter table items_detailed
drop column product_category;

alter table items_detailed
rename column category_english to product_category;;


-- ==========================================================
-- STEP 2: BUSINESS ANALYSIS & INSIGHTS
-- Queries used for the final report
-- ==========================================================

-- Payment installments & ave_check
select 
	payment_installments, 
	count(*),
	avg(total_payment) as ave_check
from orders_detailed
group by payment_installments
order by 1;


-- total revenue of the marketplace
select
	sum(price) as revenue
from items_detailed;


-- revenue and orders count by seller
select
	seller_id,
	sum(price) as revenue,
	count(*) as orders_count
from items_detailed
group by seller_id
order by orders_count desc;


-- orders by basket size
select
	basket_size,
	avg(items_total_price) as ave_check,
	avg(price_per_item) as ave_item_price,
	count(*) as orders_count
from orders_detailed
group by basket_size
order by basket_size;



-- Delivery delay and review score
select case
	when delivery_delay > '100 days' then '> 100 days'
	when delivery_delay > '50 days' then '50-99 days'
	when delivery_delay > '30 days' then '30-49 days'
	when delivery_delay > '21 days' then '21-29 days'
	when delivery_delay > '14 days' then '14-20 days'
	when delivery_delay > '7 days' then '7-14 days'
	when delivery_delay > '5 days' then '5-6 days'
	when delivery_delay > '3 days' then '3-4 days'
	when delivery_delay > '2 days' then '2 days'
	when delivery_delay > '1 day' then '1 day'
	when delivery_delay > '12:00:00' then '12-24 hours'
	when delivery_delay > '6:00:00' then '6-12 hours'
	when delivery_delay > '0:00:00' then 'up to 6 hours'
	else 'no delay' end as delay,
	avg(review_score) as review_rating,
	count(review_score)
from orders_detailed
group by delay
order by review_rating desc;


-- revenue by categories
select
	product_category,
	avg(price) as ave_price,
	count(order_id) as ordered_times,
	count(product_id) * avg(price) as revenue
from items_detailed
group by product_category
order by revenue desc;


-- ave price across top-13 categories
select
	product_category,
	avg(price) as ave_price
from items_detailed
where product_category in ('health_beauty', 'watches_gifts', 'bed_bath_table', 'sports_leisure', 'computers_accessories', 'furniture_decor', 'cool_stuff', 'housewares', 'auto', 'garden_tools', 'toys', 'baby', 'perfumery')
group by product_category;


-- average review score of top categories
select
	product_category,
	avg(review_score) as ave_rating
from orders_detailed left join items_detailed using (order_id)
where product_category in ('health_beauty', 'watches_gifts', 'bed_bath_table', 'sports_leisure', 'computers_accessories', 'furniture_decor', 'cool_stuff', 'housewares', 'auto', 'garden_tools', 'toys', 'baby', 'perfumery')
group by product_category
order by ave_rating desc;


-- payment types
select
	payment_type,
	sum(payment_value) as total_revenue,
	avg(items_total_price) as ave_price,
	count(payment_value) as orders_count
from orders_detailed left join order_payments using (order_id)
where order_status = 'delivered'
group by payment_type
order by 2;


-- payment type controlling category
-- maybe delete
select
	payment_type,
	sum(payment_value),
	avg(items_total_price) as ave_price,
	count(payment_value)
from orders_detailed o left join order_payments p using (order_id) left join items_detailed i using (order_id)
where o.order_status = 'delivered' and i.product_category = 'electronics'
group by payment_type
order by 2;



-- difference between orders total cost and total amount paid by customers (checking data consistency)
-- 2831
WITH order_costs AS (
    SELECT 
        order_id,
        SUM(items_total_price + freight_total) as order_cost
    FROM orders_detailed
    WHERE order_status = 'delivered'
    GROUP BY order_id
),
payment_costs AS (
    -- Считаем платежи отдельно
    SELECT 
        order_id,
        SUM(payment_value) as total_paid
    FROM order_payments
    GROUP BY order_id
)
SELECT
    SUM(oc.order_cost) - SUM(pc.total_paid) as diff
FROM order_costs oc
JOIN payment_costs pc USING (order_id)
WHERE oc.order_cost != pc.total_paid;



-- orders by status
select
	order_status, 
	count(*), 
	avg(freight_total) as ave_freight,
	avg(total_payment) as ave_check
from orders_detailed
group by order_status;


-- orders count in 2018
select
	count(*)
from orders_detailed
where order_purchase_timestamp between '2018-01-01' and '2018-08-31' and order_status != 'cancelled';


-- ave orders count per city
with cte as (
select
	customer_city,
	count(*) as orders_count
from orders_detailed o
group by customer_city
order by 2 desc
)

select avg(orders_count)
from cte;


-- number of sellers by city
with cte as (
select distinct
	seller_id,
	seller_city
from items_detailed
)

select 
	seller_city,
	count(*) as sellers_count
from cte
group by seller_city
order by sellers_count desc;
