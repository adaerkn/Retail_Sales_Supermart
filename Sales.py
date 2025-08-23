import pandas as pd

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

dataset = pd.read_csv("Supermart Grocery Sales - Retail Analytics Dataset.csv")


print(dataset.head(10))


print(dataset.columns)

#Category Oil&Masala olanların kar oranı görünsün

#1. yol
profit_category= dataset.groupby(["Category"])[["Profit"]].sum().sort_values(by="Profit", ascending=False)
print(profit_category.loc["Oil & Masala"])

# 2. yol category sınıflandırarak istediğim columnları seçerek alt küme veri seti oluştur [[]]
oil_category=dataset[dataset["Category"]=="Oil & Masala"]["Profit"].sum()
print(oil_category)

#categorylerin profitlerini gösteren analizimiz
print(profit_category)

print(dataset["Region"])

region_sales=dataset[dataset["Region"]=="South"]
sales=region_sales.groupby(["Region","City","Sub Category"])[["Sales"]].sum().sort_values(by="Sales", ascending=False)
print(sales)


#aylık satış trendini gösteren grafik

#Sub_category == Rice olsun

rice_sub=dataset[dataset["Sub Category"]=="Rice"]
rice_group=rice_sub.groupby(["Region"])["Sales"].sum().reset_index()

plt.figure(figsize = (10,10))
plt.bar(x= rice_group["Region"], height= rice_group["Sales"], data= rice_group)
plt.title("Bölgelere Göre Pirinç Satışları")
plt.xlabel("Bölgeler")
plt.ylabel("Toplam Satışlar")
plt.show()



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


#Maliyet hesaplama gösteren işlem satış-profit
dataset["Cost"]= dataset["Sales"]-dataset["Profit"]
print(dataset[["Cost","Category","Sub Category"]])


#maliyetleri toplam kategori bazında gösterin
category_cost= dataset.groupby(["Category"])[["Cost"]].sum().sort_values(by="Cost", ascending=False)
print(category_cost)



#Ortalama üstünü gösteren satış
mean_sales=dataset["Sales"].mean()
new_retail= dataset[dataset["Sales"]>= mean_sales] 
print(new_retail[["Sales", "Category","Sub Category"]])



category_mean= new_retail.groupby(["Category","Sub Category"])[["Sales"]].sum().sort_values(by="Sales", ascending=False).reset_index()
print(category_mean)

plt.figure(figsize=(10,10))
sns.barplot(x="Category", y="Sales" ,data=category_mean ) 
plt.xlabel("Category")
plt.ylabel("Sales")
plt.xticks(rotation=90)
plt.show()

#chocolates kategorisindeki discount ve şehir indirim oranlarını gösteren bir lineplot oluştur

choco_sub= dataset[dataset["Sub Category"]=="Chocolates"]
choco_discount= choco_sub.groupby(["Region"])[["Discount"]].sum().reset_index()
print(choco_discount)

plt.figure(figsize=(10,10))
sns.lineplot(x="Region", y="Discount", data=choco_discount)
plt.xlabel("Region")
plt.ylabel("Discount")
plt.xticks(rotation=90)
plt.show()

