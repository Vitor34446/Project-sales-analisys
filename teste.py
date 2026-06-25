import pandas as pd
from load_data import load_all_dtype_data

file = load_all_dtype_data()
fv = file["Fato_Vendas_No_Outliers"]
dcl = file["Dim_Cliente"]

print(dcl["Data_Cadastro"])