import logging
from load_data import clean_data

col_ignore = ["ID_Venda", "ID_Produto","ID_Cliente","ID_Cidade","ID_cliente"]

file = clean_data()
fv = file["Fato_Vendas"]
dcl = file["Dim_Cliente"]

df = (fv.
      merge(dcl,on='ID_Cliente',how='left')
)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

for name, df in file.items():

    numeric = df.select_dtypes(include="number").drop(columns= col_ignore,errors="ignore")

    # corr = numeric.corr()

    # corr.to_csv(f"{name}_correlation.csv")

    # describe = numeric.describe()

    # describe.to_csv(f"{name}_describe.csv")

    logging.info(f"Analising table {name}")

    logging.info("Null values")
    logging.info(df.isnull().sum())

    logging.info("Data type")
    logging.info(df.dtypes)

    logging.info("Duplicated values")
    logging.info(df.duplicated().sum())

    logging.info("correlation")
    logging.info(numeric.corr())

    logging.info("Describe")
    logging.info(numeric.describe())

    logging.info("Unique values")
    logging.info(numeric.nunique())

    logging.info("Random lines")
    logging.info(df.sample(5))
