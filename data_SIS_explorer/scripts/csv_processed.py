import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler


# NOTE: Data:
# NOTE: Comorbilidades: CON_DX_OBESIDAD, CON_DX_HIPERTENSION, CON_DX_SALUDMENTAL.
# NOTE: Atenciones médicas: CANT_ATENCIONES.
# NOTE: Hospitalizaciones: CANT_ATENCIONES_HOSP, DIAS_HOSP.

csv_processed = r'R:\data_science\laboratory\projects\data_SIS_explorer\data\processed\obe_hiper_mental_preprocessed.csv'

df = pd.read_csv(csv_processed)

# print(df.info())
# print(df.columns)

print(df[['CON_DX_OBESIDAD', 'CON_DX_HIPERTENSION', 'CON_DX_SALUDMENTAL']].head())

# NOTE: Score de riesgo basodo en comorbilidades y hospitalizaciones 

df['SCORE_RIESGO'] = (
    df['CON_DX_OBESIDAD'] +
    df['CON_DX_HIPERTENSION'] +
    df['CON_DX_SALUDMENTAL'] +
    df['CANT_ATENCIONES'] +
    (df['CANT_ATENCIONES_HOSP'] * 2) + 
    df['DIAS_HOSP']
)

def risk_segment(score):
    if score <= 2:
        return 'Bajo riesgo'
    elif score <= 5:
        return 'Riesgo moderado'
    else:
        return 'Alto riesgo'

df['SEGMENTO_RIESGO'] = df['SCORE_RIESGO'].apply(risk_segment)

print(df[['SCORE_RIESGO', 'SEGMENTO_RIESGO']].value_counts())

# NOTE: KMeans

features = df[[
    'CON_DX_OBESIDAD',
    'CON_DX_HIPERTENSION',
    'CON_DX_SALUDMENTAL',
    'CANT_ATENCIONES',
    'CANT_ATENCIONES_HOSP',
    'DIAS_HOSP', 'SCORE_RIESGO']]
scaler = StandardScaler()
features_scaled = scaler.fit_transform(features)
kmeans = KMeans(n_clusters=3, random_state=42)
df['RISK_CLUSTER'] = kmeans.fit_predict(features_scaled)

print(df[['CODIGO_ANONIMIZADO', 'SCORE_RIESGO', 'SEGMENTO_RIESGO', 'RISK_CLUSTER']].head(20))

# NOTE: Visualización

plt.figure(figsize=(12, 8))
sns.scatterplot(data=df, x='CANT_ATENCIONES', y='SCORE_RIESGO', hue='RISK_CLUSTER', style='SEGMENTO_RIESGO', palette='deep', s=100)

plt.title('Distribución de Pacientes por Atenciones Médicas y Score de Riesgo', fontsize=16)
plt.xlabel('Cantidad de Atenciones Médicas', fontsize=14)
plt.ylabel('Score de Riesgo', fontsize=14)
plt.legend(title='Clúster de Riesgo', loc='upper right')
plt.grid(True)
ruta_save = r'R:\data_science\laboratory\projects\data_SIS_explorer\reports\figures\atenciones_vs_score_outcome1.png'
plt.savefig(ruta_save, bbox_inches='tight')
plt.show()
