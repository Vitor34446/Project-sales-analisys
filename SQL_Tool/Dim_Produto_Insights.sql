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
SUM(((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Produto, dp.ID_Produto
ORDER BY Lucro_Real desc;

SELECT * FROM Produto;

-- the most profitable categorie --

DROP TABLE IF EXISTS Categoria;

CREATE TABLE Categoria AS

SELECT dp.Categoria,
dp.ID_Produto,
COUNT(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Categoria, dp.ID_Produto
ORDER BY Lucro_Real desc;

SELECT * FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv')fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
WHERE Categoria == 'Monitor';

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
SUM(((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_RealProfit2.csv') fv
JOIN Produto p
    on fv.ID_Produto = p.ID_Produto
join Categoria c
    on fv.ID_Produto = c.ID_Produto
join Marca m
    on fv.ID_Produto = m.ID_Produto
GROUP BY p.Produto, c.Categoria, m.Marca
ORDER BY Lucro_Real desc;

-- Classification by product price --

SELECT MAX(Preco_Unitario),
MIN(Preco_Unitario),
FROM
read_csv_auto('processed_tables/Fato_Vendas.csv');

DROP TABLE if EXISTS Categorie_Product;

CREATE TABLE Categorie_Product AS 

SELECT *,
    CASE 
        WHEN Preco_Unitario <= 200 THEN 'Cheap'
        WHEN Preco_Unitario <= 1000 THEN 'Mean'
        WHEN Preco_Unitario <= 3000 THEN 'Expensive'
        ELSE 'Very Expensive'
    END AS Product_Categorie
FROM read_csv_auto('processed_tables/Fato_Vendas_Lucro.csv');

SELECT Product_Categorie, count(*) qtd
FROM Categorie_Product
GROUP BY Product_Categorie
ORDER BY qtd;

SELECT
    Product_Categorie,
    ROUND(SUM((Preco_Unitario * Quantidade) - Desconto)) AS Receita,
    ROUND(SUM(Custo_Unitario * Quantidade)) AS Custo,
    ROUND(SUM(
        ((Preco_Unitario * Quantidade) - Desconto)
        - (Custo_Unitario * Quantidade)
    )) AS Lucro,
    ROUND(
        100.0 * SUM(
            ((Preco_Unitario * Quantidade) - Desconto)
            - (Custo_Unitario * Quantidade)
        )
        /
        SUM((Preco_Unitario * Quantidade) - Desconto),
        2
    ) AS Margem_Lucro_Percentual
FROM Categorie_Product
GROUP BY Product_Categorie
ORDER BY Margem_Lucro_Percentual;


SELECT * FROM read_csv('processed_tables/Dim_Produto_dtype.csv')
WHERE Produto = 'Monitor Gamer 165Hz';

-- discount in each product --

SELECT
    dp.Produto,
    AVG(fv.Desconto / (fv.Preco_Unitario * fv.Quantidade)) * 100 AS desconto_medio_percentual
FROM read_csv_auto('processed_tables/Fato_Vendas_Lucro.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
GROUP BY dp.Produto
ORDER BY desconto_medio_percentual DESC;


WITH Lucro AS(
    SELECT
        SUM(
            (
                (fv.Preco_Unitario * fv.Quantidade)
                - fv.Desconto
            )
            -
            (fv.Custo_Unitario * fv.Quantidade)
        ) AS lucro_monitor,

        SUM(
            (
                fv.Preco_Unitario * fv.Quantidade * 0.70
            )
            -
            (fv.Custo_Unitario * fv.Quantidade)
        ) AS lucro_com_30
        --FROM Categorie_Product fv
        FROM read_csv_auto('processed_tables/Fato_Vendas_Lucro.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    ON fv.ID_Produto = dp.ID_Produto
--WHERE fv.Product_Categorie = 'Expensive'
WHERE dp.Produto = 'Monitor Gamer 165Hz'
GROUP BY dp.Produto
)
SELECT
    lucro_monitor,
    lucro_com_30,
    lucro_com_30/lucro_monitor * 100
    FROM Lucro;


