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
Select distinct [Category] from supermarkt --unique deðerler için 

-- Bakery kategorisinden alýþveriþ yapan müþterileri
Select [Customer Name] from supermarkt
where [Category] = 'Bakery'
order by [Category]


-- azalan için desc artan için asc
-- Sipariþ baþýna Maliyet hesaplansýn 
Select [Sub Category], [Sales]-[Profit] as Cost 
from supermarkt
order by Cost desc


--JOIN SORGULARI

drop table Costumer_info
Create Table Customer_info (
[Customer Name] varchar(250) primary key,
[Phone Number] int )


-- seçtiðim kýsýmda yani ortak olmayanlarý göstersin
select CI.[Customer Name] from Customer_info CI
right join supermarkt SP
On CI.[Customer Name]=SP.[Customer Name]
Where SP.[Customer Name] is null



-- veri uyumsuzluðunu gidermek için yukarýdaki sonuç döndürürse bunu yapman lazým ???
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

--müþeteri id ve phone number gözüksün baðlantýyý isimlerden kuruyoruz!

select SP.[Customer Name] ,[Order ID], CI.[Phone Number],[Sub Category] from supermarkt SP
inner join Customer_info CI
on SP.[Customer Name]= CI.[Customer Name]


--En çok alýþveriþ yapan ilk 10 müþteri adý, alt kategorisi ve sales deðeri çýksýn
--desc 

Select top 10 [Customer Name] as Top_10_Customer, [Sub Category], Sum([Sales]) as Sales from supermarkt
group by [Customer Name], [Sub Category]
order by Sales desc;

select top 2 * from supermarkt

---ortalamanýn üstündeki satýþlarýn kategorileri müþteri adý ve satýþý gözüksün 
--eklemeye çalýþ satýþ avg üstündeyse sütun adý büyük satýþ olsun

select [Customer Name],[Category],[Sub Category],[Sales] as BuyukSatis
	from supermarkt
Group by [Customer Name],[Category],[Sub Category], [Sales]
Having [Sales] >= (Select AVG([Sales]) from supermarkt)
Order By [Sales] desc
-- ben ortalama deðerinin yani selectli ifadeden büyükleri istiyorum bu yüzden 
--HAVING [Sales] >= AVG([Sales]) ifadesi, her bir satýrýn kendi satýþ deðerini,
-- tüm tablonun ortalamasý yerine o satýrdaki satýþýn ortalamasý ile karþýlaþtýrýr.



-- over derken bir þey üzerinden sýralama yapmamý istiyorum sýralamadan dolayý da içinde order by kullandýk
-- Window functions: ROW_NUMBER(), RANK().

--RANK
--Categoryleri toplam satýþýna göre sýralama yap
Select [Category], SUM([Sales]) as ToplamSatis,rank() over (order by SUM([Sales]) desc) AS SatisSiralama
from supermarkt
group by [Category]
order by  SatisSiralama


--GROUP BY ifadesi: GROUP BY yalnýzca SELECT listesindeki toplama yapýlmayan (SUM, AVG, COUNT gibi fonksiyonlarla kullanýlmayan) sütunlarý içermelidir.
-- Bu durumda sadece [Category] sütunu gruplama için yeterlidir

-- ORDER BY ifadesi: Son olarak, sonuçlarý sýralamak için ORDER BY ifadesini kullanýrken, SatisSiralama adlý yeni oluþturduðunuz sütunu referans alabilirsiniz. 
--Bu, en yüksek satýþa sahip kategoriyi en üstte görmenizi saðlar.

--ROW_NUMBER()
--over ile kullanýlýr

--SQL'de ROW_NUMBER() fonksiyonu, bir sonuç kümesindeki her bir satýra, belirli bir kritere göre artan bir sýra numarasý atamak için kullanýlýr.
-- RANK()'tan farký, ayný deðere sahip satýrlara bile benzersiz bir sýra numarasý vermesidir.



--Þehirlerdeki satýþa göre sýralama yap

select [City], SUM([Sales]) as Satis, row_number() over( order by SUM([Sales]) desc) as SehirSatis
from supermarkt
group by [City]
order by SehirSatis;



select top 10 * from Customer_info

-- 1. South bölgesine ait, category bazlý toplam satýþ ve kar inceleme
Select [Category] ,Sum([Sales]) as Total_Sales , SUM([Profit]) as Total_Profit from supermarkt
Where [Region] = 'South'
Group by [Category]
Order by Total_Sales desc;

--2 Egg & Meat & Fish kategorisinde müþteri baþýna ortalama harcama
Select  distinct [Customer Name], Sum([Sales]) as Customer_Sales from supermarkt
where [Category]= 'Egg& Meat & Fish'
group by [Customer Name]
order by Customer_Sales desc;

--3. En fazla harcama yapan 10 deðerli müþteri
select top 10 c.[Customer Name] , Sum(s.[Sales]) as total_spent from supermarkt s
inner join Customer_info c on c.[Customer Name]=s.[Customer Name]
group by c.[Customer Name]
order by total_spent desc 

select top 10 * from supermarkt
--4. yýllýk satýþ trendi, category = Fruits & Veggies format methodu kullan??
-- FORMAT(tarih_kolonu, 'biçim')

Select Format( [Order Date] , 'yyyy') as sale_year, sum([Sales]) as total_Sales from supermarkt 
where [Category] = 'Fruits & Veggies' 
group by Format( [Order Date] , 'yyyy')
order by total_Sales desc;


-- 5. Snacks kategorisinde, satýþa göre alt kategori sýralamasý
Select top 5 [Sub Category], Sum([Sales]) as Top_Snacks
from supermarkt
where [Category]='Snacks'
group by [Sub Category]
order by Top_Snacks desc;


--yüzdelik artýþý hesaplamak için LAG fonksiyonunu kullanabiliriz. Bu fonksiyon, bir önceki satýrdaki deðere eriþmenizi saðlar, bu sayede her yýl için -
--bir önceki yýlýn satýþ rakamýna ulaþýp büyümeyi hesaplayabilirsiniz.

-- 6. yýllýk büyüme oraný 

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