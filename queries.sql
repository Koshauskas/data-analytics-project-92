--question 4
select 
--calculate all customers by customer_id which is unique
COUNT(customer_id) as customers_count 
from customers c 

--question 5
--query1
select 
e.first_name || ' ' || e.last_name as seller,
count(s.sales_id) as operations,
floor(sum(s.quantity*p.price)) as income
--this query calculates revenue by sellers, sorts it from highest to lowest and filters the top 10 sellers
from sales s 
left join employees e 
on s.sales_person_id=e.employee_id
left join products p 
on s.product_id = p.product_id
group by seller 
order by income desc 
limit 10;

--query2
select 
e.first_name || ' ' || e.last_name as seller,
floor(avg(s.quantity*p.price)) as average_income
--this query finds sellers whose average revenue is less than the average revenue of all sellers
--and sorts by revenue from lowest to highest
from sales s 
join employees e 
on s.sales_person_id=e.employee_id
join products p 
on s.product_id = p.product_id
group by seller 
having avg(s.quantity*p.price) < (
select avg(s.quantity*p.price)
from sales s 
join products p 
on s.product_id = p.product_id ) 
order by average_income asc;

--query3
select 
e.first_name || ' ' || e.last_name as seller,
trim(to_char(s.sale_date, 'Day')) as day_of_week,
floor(sum(s.quantity*p.price)) as income
--this query finds revenue sorted by day of week and sellers
from sales s 
join employees e 
on s.sales_person_id=e.employee_id
join products p 
on s.product_id = p.product_id
group by seller, day_of_week, 
case  
	when extract(dow from s.sale_date) = 0 then 7
	else extract(dow from s.sale_date)
end
order by
case  
	when extract(dow from s.sale_date) = 0 then 7
	else extract(dow from s.sale_date)
end, 
seller