import pandas as pd
from load_data import clean_data

file = clean_data()
fv = file["Fato_Vendas"]

fv["Cost"] = fv["Custo_Unitario"] * fv["Quantidade"]
fv["Recept"] = fv["Preco_Unitario"] * fv["Quantidade"]
fv["Recept_Cost"] = fv["Cost"]/fv["Recept"]

mean_by_quantity = (
    fv.groupby("Quantidade")["Recept_Cost"]
      .mean()
      .reset_index()
)

print(mean_by_quantity)

fv["Price_Range"] = pd.cut(
    fv["Preco_Unitario"],
    bins=[0, 200, 1000, 3000, float("inf")],
    labels=[
        "Very Cheap",
        "Cheap",
        "Expensive",
        "Very Expensive"
    ],
    include_lowest=True
)

quant_per_price =(
    fv.groupby("Quantidade")["Quantidade"]
    .sum()
    .reset_index(name="Qtd")
)
print(quant_per_price)

mean_by_price = (
    fv.groupby("Price_Range")["Recept_Cost"]
      .mean()
      .reset_index()
)

print(mean_by_price)

negatives = fv[fv["Lucro_Real"] < 0]

result_Price =(
    negatives.groupby("Price_Range")["Lucro_Real"]
    .sum()
    .reset_index(name="Qtd_Prejudize")
)

print(result_Price)

result_Quant =(
    negatives.groupby("Quantidade")["Lucro_Real"]
    .sum()
    .reset_index(name="Qtd_Prejudize")
)

print(result_Quant)

resultado = pd.crosstab(
    fv["Quantidade"],
    fv["Price_Range"]
)

print(resultado)

fv["Perc_Desconto"] = (
    fv["Desconto"] /
    (fv["Preco_Unitario"] * fv["Quantidade"])
)

teste = fv.groupby("Quantidade")["Perc_Desconto"].mean()

print(teste)

fv.to_csv("processed_tables/Fato_Vendas.csv", index=False)