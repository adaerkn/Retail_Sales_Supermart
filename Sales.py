import pandas as pd

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

dataset = pd.read_csv("Supermart Grocery Sales - Retail Analytics Dataset.csv")

#py dosyası olduğu için print yazmam lazım

print(dataset.head(10))

#pivot benzeri analizler groupby yardımıyla
#matplotlib aylık satış trendi grafiği


print(dataset.columns)

#Category Oil&Masala olanların kar oranı görünsün

#profit_category= dataset.groupby(["Category"]=="Oils & Masala")[["Profit"]].sum().sort_values(by="Profit", ascending=False)
#print(profit_category)
#bu şekilde çalışmaz
#Oil masala nın görünmesi için önce sadece onu sınıflandırmalıyım ayrı veri seti olarak
# ya da sadece .loc[istediğim şey] yaparak da bulabilirim kısaca

#1. yol
profit_category= dataset.groupby(["Category"])[["Profit"]].sum().sort_values(by="Profit", ascending=False)
print(profit_category.loc["Oil & Masala"])

# 2. yol category sınıflandırarak istediğim columnları seçerek alt küme veri seti oluştur [[]]
oil_category=dataset[dataset["Category"]=="Oil & Masala"]["Profit"].sum()
print(oil_category)

#categorylerin profitlerini gösteren analizimiz
print(profit_category)

print(dataset["Region"])
# Region= South olanların sales, city, sub category görünsün
#region_sales=dataset[dataset["Region"]=="South"] sadece böyle olursa south olan gözükür
region_sales=dataset[dataset["Region"]=="South"]
sales=region_sales.groupby(["Region","City","Sub Category"])[["Sales"]].sum().sort_values(by="Sales", ascending=False)
print(sales)


#aylık satış trendini gösteren grafik

#Sub_category == Rice olsun

#datamı sınıflandırmam lazım!
rice_sub=dataset[dataset["Sub Category"]=="Rice"]
# satışları gruplandırman lazım bölgelere göre
rice_group=rice_sub.groupby(["Region"])["Sales"].sum().reset_index()
#Sales sütununda sum işlemim uygulanır
plt.figure(figsize = (10,10))
plt.bar(x= rice_group["Region"], height= rice_group["Sales"], data= rice_group)
plt.title("Bölgelere Göre Pirinç Satışları")
plt.xlabel("Bölgeler")
plt.ylabel("Toplam Satışlar")
plt.show()

#key error hatası almamak için reset_index kullan

#Health drinks kategorime ait yıllık satış verisi olsun
health_drinks=dataset[dataset["Sub Category"]==("Health Drinks")]
health_drinks["Order Date"]=pd.to_datetime(health_drinks["Order Date"],  format='mixed')
health_drinks_year= health_drinks[health_drinks["Order Date"].dt.year >= 2015] #adı artık sütunun dt.year ile birlikte
year_sales= health_drinks_year.groupby(health_drinks_year["Order Date"].dt.year)["Sales"].sum().reset_index()

print(year_sales)

plt.figure(figsize = (10,10))
plt.bar(x=year_sales["Order Date"], height= year_sales["Sales"], data= year_sales)
plt.xticks(year_sales["Order Date"])
plt.title("Yıllara göre Sağlık içeceklerin satış tutarı")
plt.show()
#2018,5 gibi gözükmemesi için plt.xticks kullanarak neye göre düzeltme istersem



#datetime formatına çevir
#dt.year komutu liste üzerinde olmaz pandas series üzerinde olur direkt group by
#yaparken [Order Date] olmuyor
