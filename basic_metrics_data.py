import pandas as pd
import logging
from load_data import load_all_raw_data
from load_data import load_all_dtype_data

file = load_all_raw_data()
file2 = load_all_dtype_data()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

for nome, df in file2.items():
    logging.info(f"Analising table {nome}")

    logging.info("Null values")
    logging.info(df.isnull().sum())

    # logging.info("Data type")
    # logging.info(df.dtypes)

    # logging.info("Duplicated values")
    # logging.info(df.duplicated().sum())
    