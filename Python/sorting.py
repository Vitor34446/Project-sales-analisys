import pandas as pd
from load_data import clean_data
from normalization import normalizar

files = clean_data()
fv = files["Fato_Vendas"]
dp = files["Dim_Produto"]
dc = files["Dim_Cidade"]
dcl = files["Dim_Cliente"]

df = (fv
      .merge(dp, on='ID_Produto',how='left')
      .merge(dc, on='ID_Cidade',how='left')
      .merge(dcl, on='ID_Cliente',how='left')
)

df = df.copy()

column_analis = "Categoria_Renda"

recept_mouth = (
    df.groupby([column_analis, pd.Grouper(key='Data_Venda', freq='ME')])['Lucro_Real']
    .sum()
    .reset_index()
)

recept_mouth["variation"] = (
    recept_mouth
    .groupby(column_analis)['Lucro_Real']
    .pct_change()
)

Coeficient_Variation = (
    df.groupby(column_analis)['Lucro_Real']
    .apply(lambda x: x.std()/ x.mean())
)

recept_mouth['grew'] = recept_mouth['variation'] > 0 
valid_Recept = recept_mouth.dropna(subset=['variation'])

Probability = (
    valid_Recept
    .groupby(column_analis)['grew']
    .mean()
    .sort_values (ascending=False)
)

Impact = (
    recept_mouth
    .groupby(column_analis)['Lucro_Real']
    .sum()
)

recept_mouth['variation'] = recept_mouth['variation'].clip(-1, 1)
valid_recept = recept_mouth.dropna(subset=['variation'])

mean_variation = valid_recept.groupby(column_analis)['variation'].mean()
volatility = valid_recept.groupby(column_analis)['variation'].std()

df_score = pd.concat([
    Probability,
    Impact,
    #mean_variation,
    volatility,
    Coeficient_Variation
], axis= 1)

df_score.columns = [
    'prob_grow',
    'total_recept',
    #'variation_mean',
    'volatility',
    'CV'
]

df_score_norm = df_score.copy()

df_score_norm['prob_grow'] = normalizar(df_score['prob_grow'])
df_score_norm['total_recept'] = normalizar(df_score['total_recept'])
# df_score_norm['variation_mean'] = normalizar(df_score['variation_mean'])
df_score_norm['volatility'] = 1-normalizar(df_score['volatility'])
df_score_norm['CV'] = 1-normalizar(df_score['CV'])

df_score_norm['score'] = (
    0.20 * df_score_norm['prob_grow'] +
    0.10 * df_score_norm['total_recept'] +
    # 0.10 * df_score_norm['variation_mean'] +
    0.30 * df_score_norm['volatility'] +
    0.40 * df_score_norm['CV']
)

ranking = df_score_norm.sort_values(by='score', ascending=False)

# print(df_score[['prob_grow', 'variation_mean', 'volatility']].corr())

print(ranking.round(3).to_markdown())

# ranking.to_csv(
#     'score_tables/age_range_score.csv',
#     #index=False
# )
