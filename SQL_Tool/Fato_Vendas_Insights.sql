-- most used pay format --

SELECT Forma_Pagamento, COUNT(*) quant
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
GROUP BY Forma_Pagamento
ORDER BY quant desc;

-- the place of the sales --

SELECT Canal_Venda, COUNT(*) quant
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
GROUP BY Canal_Venda
ORDER BY quant desc;

-- the real profit --

SELECT
dp.Produto,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY  dp.Produto
ORDER BY Lucro_Real desc;

-- profit over year --

SELECT 
EXTRACT(YEAR FROM Data_Venda) ano,
SUM(((Preco_Unitario - Desconto) * Quantidade)
-(Quantidade * Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv')
GROUP BY ano
ORDER BY ano desc;

-- profit over month --

SELECT 
EXTRACT(YEAR FROM Data_Venda) ano,
EXTRACT(MONTH FROM Data_Venda) mes,
SUM(((Preco_Unitario - Desconto) * Quantidade)
-(Quantidade * Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv')
GROUP BY mes, ano
ORDER BY mes, ano desc;

-- create table with the column of the real profit --
DROP TABLE if exists Fato_Vendas_RealProfit;

CREATE TABLE Fato_Vendas_RealProfit AS 

SELECT *,
((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv;

COPY Fato_Vendas_RealProfit 
TO 'processed_tables/Fato_Vendas_Lucro.csv'
WITH (HEADER, DELIMITER ';');

SELECT * FROM Fato_Vendas_RealProfit;


