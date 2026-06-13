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

