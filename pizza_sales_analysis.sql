-- Retrieve the total number of orders placed.
SELECT  distinct count(order_id) as total_orders FROM pizza_sales.orders;

-- Calculate the total revenue generated from pizza sales.
select sum(t1.price*t2.quantity) as total_revenue from pizza_sales.pizzas t1
join pizza_sales.order_details t2
on t1.pizza_id=t2.pizza_id;

-- Identify the highest-priced pizza.
select t1.pizza_type_id,t2.name,t1.price from pizza_sales.pizzas t1
join pizza_sales.pizza_types t2
on t1.pizza_type_id = t2.pizza_type_id
order by t1.price desc limit 1;


-- Identify the most common pizza size ordered.
select t1.size,count(t2.order_details_id)as freq from pizza_sales.pizzas t1
join pizza_sales.order_details t2
on t1.pizza_id=t2.pizza_id
group by t1.size
order by freq desc ;

-- List the top 5 most ordered pizza types along with their quantities.
select t1.pizza_type_id, sum(t2.quantity)  as quantities  from pizza_sales.pizzas t1
join pizza_sales.order_details t2
on t1.pizza_id = t2.pizza_id
group by t1.pizza_type_id
order by quantities desc  limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered
select t3.category,sum(t1.quantity) as total_order from pizza_sales.order_details t1
join pizza_sales.pizzas t2
on t1.pizza_id = t2.pizza_id 
join pizza_sales.pizza_types t3
on t2.pizza_type_id = t3.pizza_type_id
group by t3.category
order by total_order desc;

-- Determine the distribution of orders by hour of the day.
select hour(time) as hour,count(*) as order_count from pizza_sales.orders
group by hour(time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) as type from pizza_sales.pizza_types
group by category;
 
 -- Group the orders by date and calculate the average number of pizzas ordered per day.
select  round(avg(total_orders),0) as avg_orders_per_day from (
 select t1.date as dates , sum(t2.quantity) as total_orders from pizza_sales.orders t1
 join pizza_sales.order_details t2
 on t1.order_id = t2.order_id 
 group by (t1.date)
 ) t;
 
 -- Determine the top 3 most ordered pizza types based on revenue.
 select distinct pizza_type,sum(revenue) over (partition by pizza_type) as total_revenue from (
  select t2.pizza_type_id as pizza_type,sum(t1.quantity) as total_orders,sum(t1.quantity)*t2.price as revenue from pizza_sales.order_details t1
 join pizza_sales.pizzas t2
 on t1.pizza_id = t2.pizza_id
 group by t2.pizza_type_id , price
 ) t
 order by total_revenue desc limit 3;
 
-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_type,
       total_revenue,
       round(total_revenue /
             sum(total_revenue) over() * 100, 2) as percentage
from (
    select t3.name as pizza_type,
           sum(t1.quantity * t2.price) as total_revenue
    from pizza_sales.order_details t1
    join pizza_sales.pizzas t2
    on t1.pizza_id = t2.pizza_id
    join pizza_sales.pizza_types t3
    on t2.pizza_type_id = t3.pizza_type_id
    group by t2.pizza_type_id , t3.name
) t
order by percentage desc;

-- Analyze the cumulative revenue generated over time.
select order_date , sum(day_sum) over(order by order_date) as cumulative_revenue from
 (select date as order_date,round(sum(t2.quantity*t3.price),0) as day_sum from pizza_sales.orders t1
 join pizza_sales.order_details t2
 on t1.order_id = t2.order_id 
 join pizza_sales.pizzas t3
 on t2.pizza_id = t3.pizza_id 
 group by t1.date) as sales;
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select * from (select pizza_type_id,category,category_sum,
 rank() over (partition by category order by category_sum desc) as category_rank from 
 (select  distinct 
 t1.pizza_type_id,t2.category, sum(t1.price*t3.quantity) 
 over (partition by t1.pizza_type_id,t2.category ) as category_sum
 from pizza_sales.pizzas t1
 join pizza_sales.pizza_types t2
 on t1.pizza_type_id = t2.pizza_type_id 
 join pizza_sales.order_details t3
 on t3.pizza_id =t1.pizza_id) as t) k
 where category_rank<=3
 
 
 