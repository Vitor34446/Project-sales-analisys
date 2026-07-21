from load_data import clean_data

file = clean_data()
fv = file["Fato_Vendas"]

print(fv)

# fv.to_csv("processed_tables/Fato_Vendas2.csv", index=False)