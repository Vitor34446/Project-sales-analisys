-- Whit group have returned the most sales --
DROP TABLE IF EXISTS Dim_Cliente_Categorizada;

CREATE TABLE Dim_Cliente_Categorizada AS

SELECT *,
    CASE
        WHEN Renda_Mensal <= 3000 THEN 'Baixa'
        WHEN Renda_Mensal <= 9000 THEN 'Media'
        WHEN Renda_Mensal <= 18000 THEN 'Alta'
        ELSE 'Muito Alta'
    END AS Categoria_Renda

FROM read_csv_auto('processed_tables/Dim_Cliente.csv');

SELECT max(Renda_Mensal) maxi, MIN(Renda_Mensal) mini
FROM Dim_Cliente_Categorizada
WHERE Renda_Mensal > 0;

SELECT Categoria_Renda, count(*) qtd
FROM Dim_Cliente_Categorizada
GROUP BY Categoria_Renda
ORDER BY qtd;

SELECT dc.Categoria_Renda,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_RealProfit.csv') fv
JOIN Dim_Cliente_Categorizada dc
    on fv.ID_Cliente = dc.ID_Cliente
GROUP BY Categoria_Renda
ORDER BY Lucro_Real desc; 

-- Whict age returned the most sales --
DROP TABLE IF EXISTS Dim_Cliente_FaixaEtaria;

CREATE table Dim_Cliente_FaixaEtaria as
select *, 
    case
        when Idade = 0 THEN null
        when Idade < 22 then 'Young'
        when Idade < 60 then 'Adult'
        else 'Elderly'
    end as Faixa_Etaria
from read_csv_auto('processed_tables/Dim_Cliente.csv');

SELECT Faixa_Etaria, count(*)qtd
FROM Dim_Cliente_FaixaEtaria
GROUP BY Faixa_Etaria
ORDER BY qtd;

SELECT df.Faixa_Etaria,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_RealProfit.csv') fv
JOIN Dim_Cliente_FaixaEtaria df
    on fv.ID_Cliente = df.ID_Cliente
GROUP BY Faixa_Etaria
ORDER BY Lucro_Real desc; 

-- whict gender returned the most sales --

SELECT df.Sexo,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Cliente_clean.csv') df
    on fv.ID_Cliente = df.ID_Cliente
GROUP BY Sexo
ORDER BY Lucro_Real desc; 

-- whict marital status returned the most sales --

SELECT df.Estado_Civil,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN read_csv_auto('processed_tables/Dim_Cliente_clean.csv') df
    on fv.ID_Cliente = df.ID_Cliente
GROUP BY Estado_Civil
ORDER BY Lucro_Real desc;

-- old clients or new ones --
DROP TABLE IF EXISTS Dim_Cliente_Cadastro;

CREATE TABLE Dim_Cliente_Cadastro AS
SELECT *,
    case
        WHEN YEAR(Data_Cadastro) >= 2025 then 'Recent'
        WHEN YEAR(Data_Cadastro) >= 2023 then 'Average'
        ELSE 'old'
    END AS Categoria_Cadastro
FROM read_csv_auto('processed_tables/Dim_Cliente.csv');

SELECT Categoria_Cadastro, count(*)qtd
FROM Dim_Cliente_Cadastro
GROUP BY Categoria_Cadastro
ORDER BY qtd;

SELECT dc.Categoria_Cadastro,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_RealProfit.csv') fv
JOIN Dim_Cliente_Cadastro dc
    on fv.ID_Cliente = dc.ID_Cliente
GROUP BY Categoria_Cadastro
ORDER BY Lucro_Real desc; 

-- What is the most profitable persona --

CREATE TABLE Costumer_Profiles AS

select c.Categoria_Cadastro,
f.Faixa_Etaria, 
r.Categoria_Renda,
SUM(fv.Quantidade) quant,
SUM(((fv.Preco_Unitario - fv.Desconto) * fv.Quantidade)
-(fv.Quantidade * fv.Custo_Unitario)) Lucro_Real,
FROM read_csv_auto('processed_tables/Fato_Vendas_clean.csv') fv
JOIN Dim_Cliente_FaixaEtaria f
    on fv.ID_Cliente = f.ID_Cliente
join Dim_Cliente_Categorizada r
    on fv.ID_Cliente = r.ID_Cliente
join Dim_Cliente_Cadastro c
    on fv.ID_Cliente = c.ID_Cliente
GROUP BY c.Categoria_Cadastro, f.Faixa_Etaria, r.Categoria_Renda
ORDER BY Lucro_Real desc;

SELECT * FROM Costumer_Profiles;

COPY Costumer_Profiles 
TO 'processed_tables/Costumer_profiles.csv'
WITH (HEADER, DELIMITER ';');

-- creating a dim_cliente with the classifications made --

CREATE TABLE Dim_Cliente AS

SELECT dc.*,
dca.Categoria_Cadastro,
dfa.Faixa_Etaria,
dcat.Categoria_Renda
FROM read_csv_auto('processed_tables/Dim_Cliente_clean.csv') dc
JOIN Dim_Cliente_Cadastro dca
    ON dc.ID_Cliente = dca.ID_Cliente
JOIN Dim_Cliente_Categorizada dcat
    ON dc.ID_Cliente = dcat.ID_Cliente
JOIN Dim_Cliente_FaixaEtaria dfa
    ON dc.ID_Cliente = dfa.ID_Cliente;

COPY Dim_Cliente 
TO 'processed_tables/Dim_Cliente.csv'
WITH (HEADER, DELIMITER ';');
