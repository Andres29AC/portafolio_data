import pandas as pd


file_mpox = r'R:\data_science\laboratory\projects\mpox_data_explorer\data\raw\monkeypox.csv'
df = pd.read_csv(file_mpox)

print(df.head())
print(df.info())
print(df.columns)

#NOTE: Outcome 1:
# Columnas de interes
# total_cases, total_deaths,new_cases, new_deaths,new_cases_smoothed, new_deaths_smoothed

columns_of_interest = ['total_cases', 'total_deaths', 'new_cases', 'new_deaths', 'new_cases_smoothed', 'new_deaths_smoothed']

print(df[columns_of_interest].head())

#NOTE: Verificar valores nulos

print(df[columns_of_interest].isnull().sum())

#NOTE: Opciones para tratar valores nulos
# 1. Eliminar filas con valores nulos
# 2. Rellenar valores nulos con una medida de tendencia central (media, mediana, moda)
# 3. Rellenar con un valor como cero 


#NOTE: Aplicando opcion 3:
df[columns_of_interest] = df[columns_of_interest].fillna(0)
print(df[columns_of_interest].isnull().sum())

output_path = 'R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome1_clean.csv'
df.to_csv(output_path, index=False)



