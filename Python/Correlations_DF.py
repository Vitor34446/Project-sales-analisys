import pandas as pd
from load_data import clean_data

files = clean_data()
dc = files["Dim_Cidade"]
dcl = files["Dim_Cliente"]
fv = files["Fato_Vendas"]
dp = files["Dim_Produto"]

df = (fv
      .merge(dp, on='ID_Produto',how='left')
      .merge(dc, on='ID_Cidade',how='left')
      .merge(dcl, on='ID_Cliente',how='left')
)

resultado = pd.crosstab(
    df["PIB_Classificacao"],
    df["Classificaçao_popula"]
)

#print(resultado)

produto = df[df['Produto'] == 'Mouse Office Basic']

print(produto['Preco_Unitario'].value_counts().sort_index())

print(produto[['Preco_Unitario', 'Quantidade']].corr())

quant = df['Quantidade'].sum()
produto_premium = produto['Quantidade'].sum()
Profit_3percent = produto_premium/quant

# print(produto_premium)
print(Profit_3percent)

receita = df['Receita'].sum()
produto_premium = produto['Receita'].sum()
var2 = produto_premium/receita

print(var2)

profit = df['Lucro_Real'].sum()
produto_premium = produto['Lucro_Real'].sum()
var3 = produto_premium/profit

print(var3)

quant = produto['Quantidade'].sum()
profit = (
    (produto['Preco_Unitario'] * produto['Quantidade'] * 0.70)
    - (produto['Custo_Unitario'] * produto['Quantidade'])
).sum()

profit_by_unit = profit / quant

cenarios = [0.05, 0.10, 0.20]

for c in cenarios:
    new_units = quant * c
    lucro_extra = new_units * profit_by_unit

    print(f"{c:.0%} of growth:")
    print(f"New units: {new_units:.0f}")
    print(f"Adicional profit: R$ {lucro_extra:,.2f}\n")


lucro_medio_cliente = (
    df.groupby("ID_Cliente")["Quantidade"]
    .mean()
    .reset_index(name="Quantidade_Media")
)

print(lucro_medio_cliente["Quantidade_Media"].mean())
print(lucro_medio_cliente["Quantidade_Media"].describe())

moda = df['Quantidade'].mode().iloc[0]
frequencia = (df['Quantidade'] == moda).sum()

print(f"Moda: {moda}")
print(f"Frequência: {frequencia}")

print(df["Quantidade"].median())

Profit_3percent= pd.crosstab(
    df["Classificaçao_popula"],
    df["Categoria_Renda"]
)

##

top10 = df['Produto'].value_counts()
print(top10)

proporcion = top10 / top10.sum()
print(proporcion)

new_sales = 8000

estimative = (proporcion * new_sales).round().astype(int)

print(estimative)

df['Lucro_Real_10'] = (
    df['Lucro_Real']
    - (df['Preco_Unitario'] * df['Quantidade'] * 0.10)
)

mean_profit_product = (
    df.groupby('Produto')['Lucro_Real_10']
      .mean()
)

mean_profit_product = mean_profit_product.loc[top10.index]

print(mean_profit_product)

estimative_profit = mean_profit_product * estimative

##

sum_estimative = estimative_profit.sum()

print(estimative_profit.to_markdown())

print(f"{estimative_profit.sum():,.2f}")

print(Profit_3percent)
## 

df['Lucro_Unidade'] = df['Lucro_Real'] / df['Quantidade']

median_profit_rent = (
    df.groupby('Categoria_Renda')['Lucro_Unidade']
      .median()
)

mean_profit_rent = (
    df.groupby('Categoria_Renda')['Lucro_Unidade'] 
      .mean()
)

std_profit_rent = (
    df.groupby('Categoria_Renda')['Lucro_Unidade'] 
      .std()
)

count_profit_rent = (
    df.groupby('Categoria_Renda')['Lucro_Unidade'] 
      .count()
)

cv= std_profit_rent/mean_profit_rent

high_salary_profit = median_profit_rent.loc["Alta"]

profit10 = high_salary_profit * 1.10

print("Mean:",mean_profit_rent)
# print("10%",profit10)
# print(cv)
print("Median:",median_profit_rent)


## 

faixa = df[df['Categoria_Renda'] == 'Alta']

limit = faixa['Lucro_Real'].quantile(0.97)

Total_Profit = faixa['Lucro_Real'].sum()
Big_Sales = faixa[faixa['Lucro_Real'] >= limit]
Big_Sales1 = df[df['Lucro_Real'] >= limit]
Other_Sales = faixa[faixa['Lucro_Real'] < limit]
Other_Profit = Other_Sales['Lucro_Real'].sum()

Profit_3percent = Big_Sales['Lucro_Real'].sum()
var2= Big_Sales['Lucro_Real'].mean()
var3= Big_Sales['Lucro_Real'].std()
var4= Big_Sales['Lucro_Unidade'].median()
cv2= var3/var2
var5 = Profit_3percent/Total_Profit

print("CV:",cv2)
print("3percent of the sales:",Profit_3percent)
print("Mean:",var2)

print("Top 3%:", Profit_3percent)
print("Others 97%:", Other_Profit)
print("Total:", Profit_3percent + Other_Profit)
print(" 3%",var4)
print("%",var5)

##

top_clientes = (
    Big_Sales.groupby('ID_Cliente', as_index=False)
    .agg(Lucro_Real=('Lucro_Real', 'sum'))
    .sort_values('Lucro_Real', ascending=False)
)

clientes = (
    df[['ID_Cliente', 'Nome']]
    .drop_duplicates(subset='ID_Cliente')
)

top_clientes = top_clientes.merge(
    clientes,
    on='ID_Cliente',
    how='left'
)

top_clientes = top_clientes[
    ['ID_Cliente', 'Nome', 'Lucro_Real']
]

print(top_clientes)

top_clientes.to_csv(
    "basic_analisys_tables/Top_Clientes.csv",
    index=False,      # Não salva o índice
    encoding="utf-8"  # Codificação
)


# print(df['Idade'].median())
