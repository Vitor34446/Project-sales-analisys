import pandas as pd

col_ignore = ["ID_Venda", "ID_Produto","ID_Cliente","ID_Cidade","ID_cliente"]

def load_all_raw_data():
    files= {
        "Dim_Cidade":pd.read_csv("Excel_tables/Dim_Cidade_Limpo.csv", sep=","),
        "Dim_Cliente":pd.read_csv("Excel_tables/Dim_Cliente.csv", sep=";"),
        "Dim_Produto":pd.read_csv("Excel_tables/Dim_Produto.csv", sep=";"),
        "Fato_Vendas":pd.read_csv("Excel_tables/Fato_Vendas.csv", sep=";")
    }

    return files

def load_all_dtype_data():
    files2= {
        "Dim_Cidade":pd.read_csv("processed_tables/Dim_Cidade_dtype.csv", sep=";"),
        "Dim_Cliente":pd.read_csv("processed_tables/Dim_Cliente_dtype.csv", sep=";"),
        "Dim_Produto":pd.read_csv("processed_tables/Dim_Produto_dtype.csv", sep=";"),
        "Fato_Vendas":pd.read_csv("processed_tables/Fato_Vendas_dtype.csv", sep=";")
    }

    files2["Dim_Cliente"]["Data_Cadastro"] = pd.to_datetime(
        files2["Dim_Cliente"]["Data_Cadastro"]
    )

    files2["Fato_Vendas"]["Data_Venda"] = pd.to_datetime(
        files2["Fato_Vendas"]["Data_Venda"]
    )

    files2["Dim_Cliente"]["Idade"] = (
        files2["Dim_Cliente"]["Idade"]
        .astype("Int64")
    )
    
    files2["Dim_Cidade"]["Populacao"] = (
    files2["Dim_Cidade"]["Populacao"]
    .str.replace(".", "", regex=False)
    .astype("Int64")
    )

    files2["Dim_Cidade"]["PIB_PerCapita"] = (
    files2["Dim_Cidade"]["PIB_PerCapita"]
    .str.replace("R$", "", regex=False)
    .str.replace(",", ".", regex=False)
    .str.replace(".", "", regex=False)
    .astype("Int64")
    )
    
    return files2

def fillna_num(files):
    for nome, df in files.items():
    
        numericos = df.select_dtypes(include="number")
        df[numericos.columns]= df[numericos.columns].fillna(0)
    
        for col in numericos.columns:
            media = numericos[col].mean()
            desvio = numericos[col].std()
            cv = desvio / media if media != 0 else 0
        
            if cv > 0.4:
                df[col] = df[col].fillna(numericos[col].median())
            else:
                df[col] = df[col].fillna(media)

    return files

def no_values_object(files):
    for name, df in files.items():
        obj = df.select_dtypes(include="object")
        files[name]= files[name].fillna("no value")

def see_outliers(files):

    outliers_dict = {}

    for name, df in files.items():
        df_clean = df.copy()

        num_col= df_clean.select_dtypes(include="number").drop(
            columns=col_ignore, errors="ignore").columns
        
        mask_total = pd.Series(False, index=df_clean.index)

    for col in num_col:

        Q1 = df[col].quantile(0.20)
        Q3 = df[col].quantile(0.80)
        IQR = Q3 - Q1
        lin_inf = max(0,Q1 - 1.5 * IQR)
        lin_sup = Q3 + 1.5 * IQR

        mask_col = (df_clean[col] < lin_inf) | (df_clean[col] > lin_sup)

        mask_total |= mask_col

    df_clean = df_clean[mask_total]

    outliers_dict[name] = df_clean
        #print(mask_col)

    return outliers_dict


def outliers_removal(files):

    outliers = see_outliers(files)
 
    files_no_outliers = {}

    for nome, df in files.items():

        if nome in outliers:

            files_no_outliers[nome] = df.drop(index=outliers[nome].index)
        else:
            files_no_outliers[nome] = df.copy()

    return files_no_outliers
    