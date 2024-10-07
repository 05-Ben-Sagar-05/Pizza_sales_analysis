create database pizza_sales;
create table orders (
order_id int not null primary key,
order_date date not null,
order_time time not null);


create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

# RETRIVE THE TOTAL NUMBER OF ORDERS PLACED
select count(order_date) from orders;

# CALCULATE THE TOTAL REVENUE GENERATED FROM PIZZA SALES
select sum(order_details.quantity*pizzas.price) as total_revenue
from pizzas join order_details
on order_details.pizza_id = pizzas.pizza_id;

# IDENTIFY THE HIGHEST PRICED PIZZA
select pizzas.price,pizza_types.name as highest_price
from pizzas join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
order by pizzas.price desc;

# IDENTIFY THE MOST COMMON PIZZA SIZE ORDERED
select pizzas.size, count(order_details.order_details_id) 
from pizzas join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizzas.size
order by pizzas.size asc;

# LIST THE TOP 5 MOST ORDERED PIZZA TYPES ALONG WITH THEIR QUANTITIES
select pizza_types.name, sum(order_details.quantity) as qty
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by qty desc
limit 5;

# JOIN NECESSARY TABLES TO FIND THE TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED
select pizza_types.category, sum(order_details.quantity) as qty
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category
order by qty desc;

# DETERMINE THE DISTRIBUTION OF ORDERS BY HOURS OF THE DAY
select hour(order_time) as hours, count(order_id) as orders from orders
group by hour(order_time);

# JOIN RELEVANT TABLES TO FIND THE CATEGORY-WISE DISTRIBUTION OF PIZZAS
select category, count(pizza_type_id) as pizzas from pizza_types
group by category order by pizzas desc;

# GROUP THE ORDERS BY DATE AND CALCULATE THE AVERAGE NUMBER OF PIZZAS ORDERED PER DAY
select avg(datas) as avg_orders from
(select orders.order_date,sum(order_details.quantity) as datas
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.order_date) as datas;

# DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE
select pizza_types.name,  
sum(order_details.quantity*pizzas.price) as revenue
from pizzas join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name 
order by revenue desc limit 3;

# CALCULATE THE PERCENTAGE CONTRIBUTIAN OF EACH PIZZA TYPE TO TOTAL REVENUE
select pizza_types.category,
sum(order_details.quantity*pizzas.price)/(select
sum(order_details.quantity*pizzas.price) as total_sales
from order_details join pizzas
on pizzas.pizza_id=order_details.pizza_id)*100 as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category 
order by revenue desc;

# ANALYZE THE CUMULATIVE REVENUE GENERATED OVER TIME
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on order_details.order_id=orders.order_id
group by orders.order_date) as sales;

# DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE FOR EACH PIZZA CATEGORY
select rank_,category,name, revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rank_
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price)as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a)as b
where rank_ <= 3;