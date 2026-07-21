-- The most profitable city -- 

select fv.ID_Cidade
,dc.Cidade,
COUNT(*) quantidade,
SUM(((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
ROUND(
        100.0 * SUM(CASE WHEN fv.Preco_Unitario <= 200 THEN fv.Quantidade ELSE 0 END)
        / SUM(fv.Quantidade),
        2
    ) AS Percentual_Baratas,
from read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Cidade.csv') dc
    on fv.ID_Cidade = dc.ID_Cidade
GROUP BY fv.ID_Cidade, dc.Cidade
ORDER BY Lucro_Real DESC;


-- What is the correlation with PIB and the profit --
DROP TABLE IF EXISTS Dim_Cidade_PIB;

CREATE TABLE Dim_Cidade_PIB AS
SELECT *,
    CASE
        WHEN TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(PIB_PerCapita, 'R$', ''),
                    '.',
                    ''
                ),
                ',',
                '.'
            ) AS DOUBLE
        ) >= 80000 THEN 'Very High'
        WHEN TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(PIB_PerCapita, 'R$', ''),
                    '.',
                    ''
                ),
                ',',
                '.'
            ) AS DOUBLE
        ) >= 60000 THEN 'High'
        WHEN TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(PIB_PerCapita, 'R$', ''),
                    '.',
                    ''
                ),
                ',',
                '.'
            ) AS DOUBLE
        ) >= 40000 THEN 'Average'
        ELSE 'Low'
    END AS PIB_Classificacao
FROM read_csv_auto('processed_tables/Dim_Cidade.csv');

SELECT * FROM Dim_Cidade_PIB;

SELECT PIB_Classificacao, count(*) qtd
FROM Dim_Cidade_PIB
GROUP BY PIB_Classificacao
ORDER BY qtd;

SELECT dp.PIB_Classificacao,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas.csv') fv
JOIN Dim_Cidade_PIB dp
    on fv.ID_Cidade = dp.ID_Cidade
GROUP BY PIB_Classificacao
ORDER BY Lucro_Real desc; 

-- What is the correlation with the population and the profit --

DROP TABLE IF EXISTS Dim_Cidade_Populacao;

CREATE TABLE Dim_Cidade_Populacao AS
SELECT *,
    CASE 
        WHEN TRY_CAST(REPLACE(Populacao,'.','') AS BIGINT) <= 1000000 THEN 'Small'
        WHEN TRY_CAST(REPLACE(Populacao,'.','') AS BIGINT) <= 5000000 THEN 'Average'
        WHEN TRY_CAST(REPLACE(Populacao,'.','') AS BIGINT) <= 9000000 THEN 'Big'
        ELSE 'Very Big'
    END AS Classificaçao_popula
FROM read_csv_auto('processed_tables/Dim_Cidade_dtype.csv');
    
SELECT Classificaçao_popula, COUNT(*) qtd
FROM Dim_Cidade_Populacao
GROUP BY Classificaçao_popula
ORDER BY qtd DESC;

SELECT * FROM Dim_Cidade_Populacao;

SELECT dp.Classificaçao_popula,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN Dim_Cidade_Populacao dp
    on fv.ID_Cidade = dp.ID_Cidade
GROUP BY Classificaçao_popula
ORDER BY Lucro_Real desc; 

-- with region is the most profitable --

SELECT dc.Regiao,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Cidade_dtype.csv') dc
    on fv.ID_Cidade = dc.ID_Cidade
GROUP BY Regiao
ORDER BY Lucro_Real desc; 

-- the city profile that is more profitable --

DROP TABLE IF EXISTS City_Profile;

CREATE TABLE City_Profile AS

SELECT dp.PIB_Classificacao,
dcp.Classificaçao_popula,
dc.Regiao,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN Dim_Cidade_PIB dp
    ON fv.ID_Cidade = dp.ID_Cidade
JOIN Dim_Cidade_Populacao dcp
    ON fv.ID_Cidade = dcp.ID_Cidade
JOIN read_csv_auto('processed_tables/Dim_Cidade_dtype.csv') dc
    ON fv.ID_Cidade = dc.ID_Cidade
GROUP BY dp.PIB_Classificacao,
dcp.Classificaçao_popula,
dc.Regiao
ORDER BY Lucro_Real desc;

SELECT * FROM City_Profile;

CREATE TABLE Dim_Cidade AS

SELECT dc.*,
dcp.Classificaçao_popula,
pib.PIB_Classificacao,
FROM read_csv_auto('processed_tables/Dim_Cidade_dtype.csv') dc
JOIN Dim_Cidade_Populacao dcp
    ON dc.ID_Cidade = dcp.ID_Cidade
JOIN Dim_Cidade_PIB pib
    ON dc.ID_Cidade = pib.ID_Cidade;

COPY Dim_Cidade 
TO 'processed_tables/Dim_Cidade.csv'
WITH (HEADER, DELIMITER ';');


select dc.Cidade,
COUNT(*) quantidade,
dp.Produto,
SUM(((fv.Preco_Unitario * fv.Quantidade) - fv.Desconto)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
from read_csv_auto('processed_tables/Fato_Vendas_dtype.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Cidade.csv') dc
    on fv.ID_Cidade = dc.ID_Cidade
JOIN read_csv_auto('processed_tables/Dim_Produto_dtype.csv') dp
    on fv.ID_Produto = dp.ID_Produto
--WHERE Produto = 'Monitor Gamer 165Hz'
GROUP BY fv.ID_Cidade, dc.Cidade, dp.Produto
ORDER BY Lucro_Real DESC;