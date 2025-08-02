--question 4
select COUNT(customer_id) as customers_count
--calculate all customers by customer_id which is unique
from customers;

--question 5
--query1
select
    e.first_name || ' ' || e.last_name as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
--this query calculates revenue by sellers, sorts it from highest to lowest
--and filters the top 10 sellers
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

--query2
select
    e.first_name || ' ' || e.last_name as seller,
    FLOOR(AVG(sl.quantity * pr.price)) as average_income
--this query finds sellers whose average revenue is less than the average 
--revenue of all sellers and sorts by revenue from lowest to highest
from sales as sl
inner join employees as e
    on sl.sales_person_id = e.employee_id
inner join products as pr
    on sl.product_id = pr.product_id
group by seller
having
    avg(s.lquantity * pr.price) < (
        select AVG(s.quantity * p.price)
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by average_income asc;

--query3
select
    e.first_name || ' ' || e.last_name as seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'day'))) as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
--this query finds revenue sorted by day of week and sellers
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    seller, day_of_week,
    case
        when EXTRACT(dow from s.sale_date) = 0 then 7
        else EXTRACT(dow from s.sale_date)
    end
order by
    case
        when EXTRACT(dow from s.sale_date) = 0 then 7
        else EXTRACT(dow from s.sale_date)
    end,
    seller;

--question 6
--query1
--this query counts the number of customers by age category
select
    '16-25' as age_category,
    COUNT(customer_id) as age_count
from customers
where age >= 16 and age <= 25
union all
select
    '26-40' as age_category,
    COUNT(customer_id) as age_count
from customers
where age >= 26 and age <= 40
union all
select
    '40+' as age_category,
    COUNT(customer_id) as age_count
from customers
where age > 40;

--query2
--this query counts the number of customers and total income by months
select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by selling_month
order by selling_month;

--query3
with first_sales as (
    select
        --this query numbers the rows within each customer_id using row_number()
        --number 1 will be the first sale purchase for each customer
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        p.price,
        ROW_NUMBER()
        over (
            partition by s.customer_id
            order by s.sale_date asc, s.sales_id asc
        )
            as rn
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
    where p.price = 0
)

select
    f.sale_date,
    c.first_name || ' ' || c.last_name as customer,
    e.first_name || ' ' || e.last_name as seller
from first_sales as f
inner join customers as c
    on f.customer_id = c.customer_id
inner join employees as e
    on f.sales_person_id = e.employee_id
where f.rn = 1
order by c.customer_id asc
