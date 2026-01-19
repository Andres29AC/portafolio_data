"""
Outcome3:
location,
iso_code,
total_cases,
total_deaths
"""
"""
TODO: Tareas pendientes
- Identificación de los países/regiones con el mayor número de casos y muertes acumulados.
- Ranking de países según los casos y muertes totales, ajustados por población.
- Mapas de calor o gráficos para visualizar el impacto geográfico.
"""
import pandas as pd

file_mpox = r'R:\data_science\laboratory\projects\mpox_data_explorer\data\raw\monkeypox.csv'
df = pd.read_csv(file_mpox)
print(df.head())


columns_of_interest = ['location', 'iso_code', 'total_cases', 'total_deaths']

print(df[columns_of_interest].head())

print(df[columns_of_interest].isnull().sum())

