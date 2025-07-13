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
trim(to_char(s.sale_date, 'day')) as day_of_week,
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

--question 6
--query1
--this query counts the number of customers by age category
select 
'16-25' as age_category,
count(customer_id) as age_count
from customers 
where age >= 16 and age <= 25
union all
select 
'26-40' as age_category,
count(customer_id) as age_count
from customers 
where age >= 26 and age <= 40
union all
select 
'40+' as age_category,
count(customer_id) as age_count
from customers 
where age > 40 

--query2
--this query counts the number of customers and total income by months
select 
to_char(s.sale_date, 'YYYY-MM') as selling_month,
count(distinct s.customer_id) as total_customers,
floor(sum(s.quantity * p.price)) as income
from sales s 
join products p 
on s.product_id=p.product_id
group by selling_month
order by selling_month

--query3
with first_sales as (
select
--this query numbers the rows within each customer_id using row_number(), number 1 will be the first sale purchase for each customer
s.customer_id,
s.sale_date,
s.sales_person_id,
row_number() over (partition by s.customer_id order by s.sale_date asc, s.sales_id asc) as rn,
p.price
from sales s 
join products p 
on s.product_id = p.product_id 
where p.price = 0
)
select 
c.first_name || ' ' || c.last_name as customer,
f.sale_date,
e.first_name || ' ' || e.last_name as seller
from first_sales f 
join customers c 
on f.customer_id = c.customer_id
join employees e 
on f.sales_person_id = e.employee_id
where f.rn = 1
order by c.customer_id asc