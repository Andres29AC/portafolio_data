import pandas as pd
import os

file_dm = r'R:\data_science\laboratory\projects\data_SIS_explorer\data\raw\Afiliados_activos_DM_SIS.csv'

df = pd.read_csv(file_dm)

# NOTE: print(df.head())
# NOTE: print(df.describe())

print(df.info())
print(df.columns)
print(df[['CON_DX_OBESIDAD', 'CON_DX_HIPERTENSION', 'CON_DX_SALUDMENTAL']].head())
# NOTE: Outcome de Compilacion

# NOTE:  1. Preprocesamiento de datos

# Conventiendo de object a variables binarias (0, 1)

df['CON_DX_OBESIDAD'] = df['CON_DX_OBESIDAD'].str.strip().apply(lambda x: 1 if x == 'SI' else 0 if pd.notna(x) else 0)
df['CON_DX_HIPERTENSION'] = df['CON_DX_HIPERTENSION'].str.strip().apply(lambda x: 1 if x == 'SI' else 0 if pd.notna(x) else 0)
df['CON_DX_SALUDMENTAL'] = df['CON_DX_SALUDMENTAL'].str.strip().apply(lambda x: 1 if x == 'SI' else 0 if pd.notna(x) else 0)

# PASSED: print(df[['CON_DX_OBESIDAD', 'CON_DX_HIPERTENSION', 'CON_DX_SALUDMENTAL']].head())

# NOTE: Guardando el archivo preprocesado

output_directory = r'R:\data_science\laboratory\projects\data_SIS_explorer\data\processed'

output_file = r'obe_hiper_mental_preprocessed.csv'

os.makedirs(output_directory, exist_ok=True)

output_path = os.path.join(output_directory, output_file)

df.to_csv(output_path, index=False)

print(f'Archivo guardado en: {output_path}')

