"""
Outcome2:
total_cases_per_million,
total_deaths_per_million,
new_cases_per_million,
new_deaths_per_million,
new_cases_smoothed_per_million,
new_deaths_smoothed_per_million
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px

file_mpox = r'R:\data_science\laboratory\projects\mpox_data_explorer\data\raw\monkeypox.csv'
df = pd.read_csv(file_mpox)

print(df.head())
print(df.columns)

columns_of_interest = ['location','total_cases_per_million', 'total_deaths_per_million', 'new_cases_per_million', 'new_deaths_per_million', 'new_cases_smoothed_per_million', 'new_deaths_smoothed_per_million']

print(df[columns_of_interest].head())
print(df[columns_of_interest].isnull().sum())
print(df[columns_of_interest].info())

select_columns_nulls = ['total_cases_per_million', 'total_deaths_per_million', 'new_cases_per_million', 'new_deaths_per_million', 'new_cases_smoothed_per_million', 'new_deaths_smoothed_per_million']

df[select_columns_nulls] = df[select_columns_nulls].fillna(df[select_columns_nulls].mean())
print(df[select_columns_nulls].isnull().sum())

data_outcome2 = df[['location'] + select_columns_nulls]

print(data_outcome2.head())
print(df[columns_of_interest].isnull().sum())


# Guardar el archivo limpio
# output_path = 'R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome2_clean.csv'
# data_outcome2.to_csv(output_path, index=False)


#NOTE: Ya tenemos un archivo limpio con los datos de interes para el Outcome data_outcome2_clean.to_csv 

#TODO: Comparación de la incidencia ajustada por población entre diferentes países o regiones.
#TODO: Análisis de correlación entre casos y muertes per cápita para observar qué lugares son más vulnerables.


df_outcome2 = pd.read_csv('R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome2_clean.csv')


# TODO: Comparación de la incidencia ajustada por población entre diferentes países o regiones.

# Agrupar por 'location' para comparar la incidencia ajustada
grouped = df_outcome2.groupby('location')[select_columns_nulls].mean()

# Mostrar las primeras filas para ver la comparación
print(grouped.head())

# Ordenar por el total de casos por millón (por ejemplo) para comparar los países o regiones con más incidencia
grouped_sorted = grouped.sort_values(by='total_cases_per_million', ascending=False)

# Mostrar los países/regiones con más casos por millón
print(grouped_sorted.head())

# Grafico con Plotly
fig = px.bar(
    grouped_sorted.reset_index().head(10),  # Mostrar las primeras 10 ubicaciones
    x='location',
    y='total_cases_per_million',
    color='total_deaths_per_million',
    title='Comparación de la incidencia de Mpox ajustada por millón',
    labels={'total_cases_per_million': 'Casos por millón', 'location': 'Ubicación'},
    color_continuous_scale='Viridis'
)

# Actualizar el diseño del gráfico
fig.update_layout(
    xaxis_title='Ubicación',
    yaxis_title='Total de casos por millón',
    coloraxis_colorbar=dict(title='Muertes por millón')
)

# Mostrar el gráfico
fig.show()


# TODO: Análisis de correlación entre casos y muertes per cápita para observar qué lugares son más vulnerables.

columns_corr = ['total_cases_per_million', 'total_deaths_per_million', 'new_cases_per_million', 'new_deaths_per_million', 'new_cases_smoothed_per_million', 'new_deaths_smoothed_per_million']


correlation = df_outcome2[columns_corr].corr()
print(correlation)

plt.figure(figsize=(10, 8))
sns.heatmap(correlation, annot=True, cmap='coolwarm', fmt='.2f', linewidths=0.5)
plt.title('Matriz de Correlación entre Casos y Muertes por Millón')
plt.show()


"""
Correlación entre Casos y Muertes Totales: La correlación entre total_cases_per_million y total_deaths_per_million es moderada (0.34). Esto sugiere que los lugares con más casos per cápita no siempre tienen una proporción directamente proporcional de muertes, lo que podría estar relacionado con factores como la calidad del sistema de salud, las medidas de prevención, y la densidad de població

Correlación entre Nuevos Casos y Muertes: La correlación entre new_cases_per_million y new_deaths_per_million es baja (0.04), lo que indica que el aumento en los nuevos casos no siempre se traduce inmediatamente en un aumento en las muertes. Esto podría deberse a factores temporales o demográficos (por ejemplo, brotes en poblaciones jóvenes donde la tasa de mortalidad es menor).

Casos Suavizados: Las variables suavizadas (smoothed_per_million) pueden ayudarte a ver tendencias a largo plazo. Por ejemplo, la correlación entre new_cases_per_million y smoothed_per_million (0.41) muestra que hay cierta consistencia en los lugares con casos nuevos recurrentes, lo que podría indicar áreas con mayor riesgo de transmisiones continuas

Identificación de Vulnerabilidad: Lugares con alta correlación entre total_cases_per_million y total_deaths_per_million podrían ser considerados más vulnerables, ya que presentan una mayor proporción de muertes con respecto a los casos.

Una conclusión preliminar podría ser que la vulnerabilidad no está totalmente ligada a la cantidad de casos, sino que hay otros factores en juego. Para profundizar, podrías combinar esta información con datos adicionales (como acceso a atención médica o edad promedio de la población) para una evaluación más completa de la vulnerabilidad por región.
"""





















