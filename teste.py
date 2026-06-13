import pandas as pd
from load_data import load_all_dtype_data
from load_data import fillna_num
from load_data import no_values_object
from load_data import outliers_removal

files = load_all_dtype_data()
files2 = fillna_num(files)
files3 = no_values_object(files)
files4 = outliers_removal(files)

for name, df in files4.items():
    print(df.isnull().sum())

# files4["Fato_Vendas"].to_csv(
#     "processed_tables/Fato_Vendas_clean.csv",
#     sep=";",
#     index=False
# )

files4["Dim_Cliente"].to_csv(
     "processed_tables/Dim_Cliente_clean.csv",
     sep=";",
     index=False
 )
