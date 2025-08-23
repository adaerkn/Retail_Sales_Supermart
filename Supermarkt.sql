create database supermarkt_retail
use supermarkt_retail

Drop table supermarkt
Create table supermarkt (
[Order ID] varchar(250) primary key,
[Customer Name] varchar(250),
[Category] varchar(250),
[Sub Category] varchar(250),
[City] varchar(250),
[Order Date] datetime,
[Region] varchar(50),
[Sales] Decimal(10,2),
[Discount] Decimal(10,2),
[Profit] Decimal(10,2),
[State] varchar(200)
)

select top 10 * from supermarkt

-- Total Category Names
Select distinct [Category] from supermarkt 

-- Bakery category customers
Select [Customer Name] from supermarkt
where [Category] = 'Bakery'
order by [Category]



-- Cost per Order
Select [Sub Category], [Sales]-[Profit] as Cost 
from supermarkt
order by Cost desc


--JOIN SORGULARI

drop table Costumer_info
Create Table Customer_info (
[Customer Name] varchar(250) primary key,
[Phone Number] int )

select CI.[Customer Name] from Customer_info CI
right join supermarkt SP
On CI.[Customer Name]=SP.[Customer Name]
Where SP.[Customer Name] is null



-- veri uyumsuzluðunu gidermek için
INSERT INTO Customer_info ([Customer Name])
SELECT DISTINCT [Customer Name]
FROM supermarkt
WHERE [Customer Name] NOT IN (SELECT [Customer Name] FROM Customer_info);

alter table supermarkt add foreign key ([Customer Name]) REFERENCES Customer_info([Customer Name]);

select [Customer Name] from Customer_info


ALTER TABLE Customer_info alter column [Phone Number] bigint;

UPDATE Customer_info SET [Phone Number] = CHECKSUM(NEWID()) % 90000000000 + 10000000000;

select [Phone Number] from Customer_info

select top 10 * from Customer_info
Select top 2 * from supermarkt

--INNER JOIN

select SP.[Customer Name] ,[Order ID], CI.[Phone Number],[Sub Category] from supermarkt SP
inner join Customer_info CI
on SP.[Customer Name]= CI.[Customer Name]


-- Top 10 customers by sales, with customer name, sub-category, and sales value


Select top 10 [Customer Name] as Top_10_Customer, [Sub Category], Sum([Sales]) as Sales from supermarkt
group by [Customer Name], [Sub Category]
order by Sales desc;



---Show the category, customer name, and sales for above-average sales.


select [Customer Name],[Category],[Sub Category],[Sales] as BuyukSatis
	from supermarkt
Group by [Customer Name],[Category],[Sub Category], [Sales]
Having [Sales] >= (Select AVG([Sales]) from supermarkt)
Order By [Sales] desc


--RANK
--Ranking categories by total sales
Select [Category], SUM([Sales]) as ToplamSatis,rank() over (order by SUM([Sales]) desc) AS SatisSiralama
from supermarkt
group by [Category]
order by  SatisSiralama



--ROW_NUMBER()
-- Ranking by sales in cities

select [City], SUM([Sales]) as Satis, row_number() over( order by SUM([Sales]) desc) as SehirSatis
from supermarkt
group by [City]
order by SehirSatis;


--  Total sales and profit analysis by category for the South region.
Select [Category] ,Sum([Sales]) as Total_Sales , SUM([Profit]) as Total_Profit from supermarkt
Where [Region] = 'South'
Group by [Category]
Order by Total_Sales desc;

--Average spending per customer in the Egg, Meat & Fish category
Select  distinct [Customer Name], Sum([Sales]) as Customer_Sales from supermarkt
where [Category]= 'Egg& Meat & Fish'
group by [Customer Name]
order by Customer_Sales desc;

--top 10 valuable customers by spending" or "top 10 highest-spending customers
select top 10 c.[Customer Name] , Sum(s.[Sales]) as total_spent from supermarkt s
inner join Customer_info c on c.[Customer Name]=s.[Customer Name]
group by c.[Customer Name]
order by total_spent desc 



-- annual sales trend, category = Fruits & Veggies"

Select Format( [Order Date] , 'yyyy') as sale_year, sum([Sales]) as total_Sales from supermarkt 
where [Category] = 'Fruits & Veggies' 
group by Format( [Order Date] , 'yyyy')
order by total_Sales desc;


-- sub-category ranking by sales in the Snacks category"
Select top 5 [Sub Category], Sum([Sales]) as Top_Snacks
from supermarkt
where [Category]='Snacks'
group by [Sub Category]
order by Top_Snacks desc;




-- annual growth rate

WITH YearlySales AS (
select YEAR([Order Date]) as sales_year,
sum([Sales]) as total_revenue from supermarkt
group by YEAR([Order Date]) )
Select sales_year, total_revenue,

 LAG(total_revenue, 1, 0) OVER (ORDER BY sales_year) AS previous_year_revenue,
    (total_revenue - LAG(total_revenue, 1, 0) OVER (ORDER BY sales_year)) * 100.0 / NULLIF(LAG(total_revenue, 1, 0)
	OVER (ORDER BY sales_year), 0) AS percentage_growth
from YearlySales
order by sales_year;

--
