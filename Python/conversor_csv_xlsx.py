from load_data import clean_data

files = clean_data()
fv = files["Fato_Vendas"]
dcl = files["Dim_Cliente"]
dc = files["Dim_Cidade"]
dp = files["Dim_Produto"]

dcl["Data_Cadastro"] = (
    dcl["Data_Cadastro"]
    .dt.tz_convert("UTC")
    .dt.date
)

# dcl['Data_Cadastro'] = dcl['Data_Cadastro'].dt.tz_localize(None)
fv['Data_Venda'] = fv['Data_Venda'].dt.tz_localize(None)

# dcl["Data_Cadastro"] = dcl["Data_Cadastro"].dt.date
fv["Data_Venda"] = fv["Data_Venda"].dt.date

# dcl.to_excel("Dim_Cliente.xlsx", index=False)
# dc.to_excel("Dim_Cidade.xlsx", index=False)
# dp.to_excel("Dim_Produto.xlsx", index=False)
fv.to_excel("Fato_Vendas2.xlsx", index=False)