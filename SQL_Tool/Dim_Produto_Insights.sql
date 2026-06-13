-- the most profitable brand --

DROP TABLE IF EXISTS Marca;

CREATE TABLE Marca AS

SELECT dp.Marca,
dp.ID_Produto,
COUNT(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Marca, dp.ID_Produto
ORDER BY Lucro_Real desc;

--the most profitable product --

DROP TABLE IF EXISTS Produto;

CREATE TABLE Produto AS

SELECT dp.Produto,
dp.ID_Produto,
COUNT(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Produto, dp.ID_Produto
ORDER BY Lucro_Real desc;

-- the most profitable categorie --

DROP TABLE IF EXISTS Categoria;

CREATE TABLE Categoria AS

SELECT dp.Categoria,
dp.ID_Produto,
COUNT(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Categoria, dp.ID_Produto
ORDER BY Lucro_Real desc;

-- what is the difference between the theoretical and the real profit --

SELECT
dp.Produto,
SUM((dp.Preco_Base - dp.Custo_Base) * fv.Quantidade) Lucro_Teorico,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
Lucro_Teorico - Lucro_Real Diferença,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY  dp.Produto
ORDER BY Lucro_Teorico desc;

-- the product profile that it's more profitable --

select p.Produto,
c.Categoria, 
m.Marca,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN Produto p
    on fv.ID_Produto = p.ID_Produto
join Categoria c
    on fv.ID_Produto = c.ID_Produto
join Marca m
    on fv.ID_Produto = m.ID_Produto
GROUP BY p.Produto, c.Categoria, m.Marca
ORDER BY Lucro_Real desc;

