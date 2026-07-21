import pandas as pd
from load_data import load_all_raw_data

files = load_all_raw_data()

coluns_numeric_float ={
    "Dim_Cliente": [" Renda_Mensal "],
    "Dim_Produto": ["Preco_Base","Custo_Base"],
    "Fato_Vendas": ["Preco_Unitario","Custo_Unitario","Receita","Desconto"]
}

for name_table,columns in coluns_numeric_float.items():
    df = files[name_table]
    for col in columns:
        df[col] = (
            df[col]
            .str.replace("R$", "", regex=False)
            .str.replace(".", "", regex=False)
            .str.replace(",", ".", regex=False)
            .str.strip()
            .astype(float)
        )

client_table = files["Dim_Cliente"]

client_table["Idade"] = (
    client_table["Idade"]
    .astype("Int64")
)

print(files["Fato_Vendas"].dtypes)
print(files["Dim_Produto"].dtypes)
print(files["Dim_Cliente"].dtypes)


colun_numeric_int = {
    "Dim_Cidade": ["Populacao","PIB_PerCapita"]
}

for name_table,columns in colun_numeric_int.items():
    df = files[name_table]
    for col in columns:
        df[col] = (
            df[col]
            
            .astype("Int64")
        )

    ## convert the datatime

coluns_data ={
    "Dim_Cliente": ["Data_Cadastro"],
    "Fato_Vendas": ["Data_Venda"]
}

for name_table, columns in coluns_data.items():

    df = files[name_table]

    for col in columns:

        df[col] = pd.to_datetime(
            df[col],
            utc=True,
            errors="coerce"
            
        )
Fato_Vendas =files["Fato_Vendas"]
Dim_Cliente =files["Dim_Cliente"]
Dim_Produto =files["Dim_Produto"]
Dim_Cidade =files["Dim_Cidade"]

df = files["Dim_Cliente"]

print(df["Data_Cadastro"].dtype)

df["Data_Cadastro"] = pd.to_datetime(
    df["Data_Cadastro"],
    utc=True,
    errors="coerce"
)

print(df["Data_Cadastro"].dtype)
#print(type(df["Data_Cadastro"].iloc[0]))
      
print(files["Dim_Cliente"].dtypes)
#print(files["Dim_Cliente"]["Data_Cadastro"].head())

    ## saving the correct dtype

client_table.to_csv(
    "processed_tables_dtype/Dim_Cliente_dtype.csv",
    sep=";",
    index=False
)

# Dim_Produto.to_csv(
#     "processed_tables/Dim_Produto_clean.csv",
#     sep=";",
#     index=False
# )

# Dim_Cidade.to_csv(
#     "processed_tables/Dim_Cidade_clean.csv",
#     sep=";",
#     index=False
# )

# Fato_Vendas.to_csv(
#     "processed_tables_dtype/Fato_Vendas_dtype.csv",
#     sep=";",
#     index=False
# )