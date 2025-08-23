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

--Toplam Ana kategorim;
Select distinct [Category] from supermarkt --unique de�erler i�in 

-- Bakery kategorisinden al��veri� yapan m��terileri
Select [Customer Name] from supermarkt
where [Category] = 'Bakery'
order by [Category]


-- azalan i�in desc artan i�in asc
-- Sipari� ba��na Maliyet hesaplans�n 
Select [Sub Category], [Sales]-[Profit] as Cost 
from supermarkt
order by Cost desc


--JOIN SORGULARI

drop table Costumer_info
Create Table Customer_info (
[Customer Name] varchar(250) primary key,
[Phone Number] int )


-- se�ti�im k�s�mda yani ortak olmayanlar� g�stersin
select CI.[Customer Name] from Customer_info CI
right join supermarkt SP
On CI.[Customer Name]=SP.[Customer Name]
Where SP.[Customer Name] is null



-- veri uyumsuzlu�unu gidermek i�in yukar�daki sonu� d�nd�r�rse bunu yapman laz�m ???
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

--m��eteri id ve phone number g�z�ks�n ba�lant�y� isimlerden kuruyoruz!

select SP.[Customer Name] ,[Order ID], CI.[Phone Number],[Sub Category] from supermarkt SP
inner join Customer_info CI
on SP.[Customer Name]= CI.[Customer Name]


--En �ok al��veri� yapan ilk 10 m��teri ad�, alt kategorisi ve sales de�eri ��ks�n
--desc 

Select top 10 [Customer Name] as Top_10_Customer, [Sub Category], Sum([Sales]) as Sales from supermarkt
group by [Customer Name], [Sub Category]
order by Sales desc;

select top 2 * from supermarkt

---ortalaman�n �st�ndeki sat��lar�n kategorileri m��teri ad� ve sat��� g�z�ks�n 
--eklemeye �al�� sat�� avg �st�ndeyse s�tun ad� b�y�k sat�� olsun

select [Customer Name],[Category],[Sub Category],[Sales] as BuyukSatis
	from supermarkt
Group by [Customer Name],[Category],[Sub Category], [Sales]
Having [Sales] >= (Select AVG([Sales]) from supermarkt)
Order By [Sales] desc
-- ben ortalama de�erinin yani selectli ifadeden b�y�kleri istiyorum bu y�zden 
--HAVING [Sales] >= AVG([Sales]) ifadesi, her bir sat�r�n kendi sat�� de�erini,
-- t�m tablonun ortalamas� yerine o sat�rdaki sat���n ortalamas� ile kar��la�t�r�r.



-- over derken bir �ey �zerinden s�ralama yapmam� istiyorum s�ralamadan dolay� da i�inde order by kulland�k
-- Window functions: ROW_NUMBER(), RANK().

--RANK
--Categoryleri toplam sat���na g�re s�ralama yap
Select [Category], SUM([Sales]) as ToplamSatis,rank() over (order by SUM([Sales]) desc) AS SatisSiralama
from supermarkt
group by [Category]
order by  SatisSiralama


--GROUP BY ifadesi: GROUP BY yaln�zca SELECT listesindeki toplama yap�lmayan (SUM, AVG, COUNT gibi fonksiyonlarla kullan�lmayan) s�tunlar� i�ermelidir.
-- Bu durumda sadece [Category] s�tunu gruplama i�in yeterlidir

-- ORDER BY ifadesi: Son olarak, sonu�lar� s�ralamak i�in ORDER BY ifadesini kullan�rken, SatisSiralama adl� yeni olu�turdu�unuz s�tunu referans alabilirsiniz. 
--Bu, en y�ksek sat��a sahip kategoriyi en �stte g�rmenizi sa�lar.

--ROW_NUMBER()
--over ile kullan�l�r

--SQL'de ROW_NUMBER() fonksiyonu, bir sonu� k�mesindeki her bir sat�ra, belirli bir kritere g�re artan bir s�ra numaras� atamak i�in kullan�l�r.
-- RANK()'tan fark�, ayn� de�ere sahip sat�rlara bile benzersiz bir s�ra numaras� vermesidir.



--�ehirlerdeki sat��a g�re s�ralama yap

select [City], SUM([Sales]) as Satis, row_number() over( order by SUM([Sales]) desc) as SehirSatis
from supermarkt
group by [City]
order by SehirSatis;



select top 10 * from Customer_info

-- 1. South b�lgesine ait, category bazl� toplam sat�� ve kar inceleme
Select [Category] ,Sum([Sales]) as Total_Sales , SUM([Profit]) as Total_Profit from supermarkt
Where [Region] = 'South'
Group by [Category]
Order by Total_Sales desc;

--2 Egg & Meat & Fish kategorisinde m��teri ba��na ortalama harcama
Select  distinct [Customer Name], Sum([Sales]) as Customer_Sales from supermarkt
where [Category]= 'Egg& Meat & Fish'
group by [Customer Name]
order by Customer_Sales desc;

--3. En fazla harcama yapan 10 de�erli m��teri
select top 10 c.[Customer Name] , Sum(s.[Sales]) as total_spent from supermarkt s
inner join Customer_info c on c.[Customer Name]=s.[Customer Name]
group by c.[Customer Name]
order by total_spent desc 

select top 10 * from supermarkt
--4. y�ll�k sat�� trendi, category = Fruits & Veggies format methodu kullan??
-- FORMAT(tarih_kolonu, 'bi�im')

Select Format( [Order Date] , 'yyyy') as sale_year, sum([Sales]) as total_Sales from supermarkt 
where [Category] = 'Fruits & Veggies' 
group by Format( [Order Date] , 'yyyy')
order by total_Sales desc;


-- 5. Snacks kategorisinde, sat��a g�re alt kategori s�ralamas�
Select top 5 [Sub Category], Sum([Sales]) as Top_Snacks
from supermarkt
where [Category]='Snacks'
group by [Sub Category]
order by Top_Snacks desc;


--y�zdelik art��� hesaplamak i�in LAG fonksiyonunu kullanabiliriz. Bu fonksiyon, bir �nceki sat�rdaki de�ere eri�menizi sa�lar, bu sayede her y�l i�in -
--bir �nceki y�l�n sat�� rakam�na ula��p b�y�meyi hesaplayabilirsiniz.

-- 6. y�ll�k b�y�me oran� 

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