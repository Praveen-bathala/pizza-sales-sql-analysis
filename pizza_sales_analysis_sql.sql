-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
-- Identify the most common pizza size ordered.
select p.size, count(od.quantity) as order_quantity
from pizzas as p
join order_details as od
on p.pizza_id = od.pizza_id
group by p.size
order by order_quantity desc;

-- List the top 5 most ordered pizza types along with their quantities.
select p.pizza_type_id, count(od.quantity) as order_quantites
from pizzas as p
join order_details as od
on p.pizza_id = od.pizza_id
group by pizza_type_id 
order by order_quantites desc
limit 5;

select pt.name, sum(od.quantity) as quantity
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id 
join order_details as od 
on p.pizza_id = od.pizza_id
group by pt.name 
order by quantity desc
limit 5;

-- Join the necessary table to find the total quantity of each pizza category
select pt.category, sum(od.quantity) as quantity
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category 
order by quantity desc
limit 5;

-- determine the distribution of orders by hour of the day
select hour(order_time) as hours, count(order_id) as hourly_orders 
from orders 
group by hours
order by hourly_orders desc;

-- category wise distribution of pizzas
select category, count(name)
from pizza_types
group by category;

-- group the orders by date and calculate the average number of pizzas ordered per day
select round(avg(quantity),2) as avg_order_per_day from
(select o.order_date, sum(od.quantity) as quantity
from orders as o 
join order_details as od
on o.order_id = od.order_id
group by o.order_date) as order_quantity;

-- determine the top 3 most ordered pizza types based on revenue
select pt.name, round(sum(od.quantity * p.price),2) as revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id = pt.pizza_type_id
join order_details as od 
on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc
limit 3;

-- calculate the percentage contribution of each pizza type to total revenue
select pt.category, round(sum(od.quantity * p.price) / (select round(sum(od.quantity * p.price),2) as total_sales
from order_details as od
join pizzas as p 
on p.pizza_id = od.pizza_id) * 100,2) as revenue
from pizza_types as pt
join pizzas as p
on p.pizza_type_id = pt.pizza_type_id
join order_details as od 
on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc
limit 3;

-- analyze the cumulative revenue generated over time
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select o.order_date, sum(od.quantity * p.price) as revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id
join orders as o
on o.order_id = od.order_id
group by o.order_date) as sales;

-- determine the top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rnk <= 3;

