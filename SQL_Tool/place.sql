SELECT * from read_csv_auto('Excel_tables/Fato_Vendas.csv');
SELECT * from read_csv_auto('Excel_tables/Dim_Cidade.csv');
SELECT * from read_csv_auto('Excel_tables/Dim_Cliente.csv');
SELECT * from read_csv_auto('Excel_tables/Dim_Produto.csv');
SELECT * from read_csv_auto('Excel_tables/Dim_Cidade_Limpo.csv');

create table Dim_Cidade_limpa as 
SELECT * from read_csv_auto('Excel_tables/Dim_Cidade.csv')
where ID_Cidade is not NULL 
and Cidade is not NULL
and Estado is not NULL
and Regiao is not NULL
and Populacao is not NULL
and PIB_PerCapita is not NULL;