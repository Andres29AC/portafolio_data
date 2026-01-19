import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns


csv_raw = r'R:\data_science\laboratory\projects\data_visitmuseos\data\raw\bd_5.csv'

df = pd.read_csv(csv_raw, sep=';', encoding='latin1')


print(df.head(20))
print(df.columns)
print(df.dtypes)



# NOTE: Proyectos:

# TODO: 1. Analisis de asistencia por tipo de museo

# WARNING:Outcome: Un informe o visualización que muestre la distribución de visitantes (adultos, niños, estudiantes, etc.) por tipo de boleto, museos y tiempo. 

        # TEST: ->FECHA_CORTE
        # TEST: ->ANIO
        # TEST: ->NOM_MES
        # TEST: ->NOM_DPTO
        # TEST: ->NOM_MUSEO
        # TEST: ->ADU_BOLESPPAGANTES
        # TEST: ->EST_BOLESPPAGANTES
        # TEST: ->NIN_BOLESPPAGANTES
        # TEST: ->MIL_BOLESPPAGANTES
        # TEST: ->ADM_BOLESPPAGANTES


choose_headers1 = ['FECHA_CORTE', 'ANIO', 'NOM_MES', 'NOM_DPTO', 'NOM_MUSEO', 'ADU_BOLESPPAGANTES', 'EST_BOLESPPAGANTES', 'NIN_BOLESPPAGANTES', 'MIL_BOLESPPAGANTES', 'ADM_BOLESPPAGANTES']

df_selected = df[choose_headers1]

output_processed1 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed1.csv'
df_selected.to_csv(output_processed1, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed1}')



# TODO: 2. Prediccion de asistencia a museos

# WARNING:Outcome: Un modelo predictivo que permita estimar la asistencia total en futuros periodos (por ejemplo, para planificación estratégica).

        # TEST: -> Variables predictoras: ANIO, NOM_MES, NOM_DPTO, COD_TIPO
        # TEST: -> Variable objetivo: TOTAL_PAGANTES 

choose_headers2 = ['ANIO', 'NOM_MES', 'NOM_DPTO', 'COD_TIPO', 'TOTAL_PAGANTES']
df_selected2 = df[choose_headers2]

output_processed2 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed2.csv'
df_selected2.to_csv(output_processed2, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed2}')




# TODO: 3. Analisis temporal y estacionalidad

# WARNING:Outcome: Gráficas y estadísticas que identifiquen patrones de estacionalidad en la asistencia a museos.

        # TEST: ->FECHA_CORTE
        # TEST: ->ANIO
        # TEST: ->NOM_MES
        # TEST: ->TOTAL_PAGANTES
        # TEST: ->TOTAL_NOPAGANTES
        # TEST: ->TOTAL

choose_headers3 = ['FECHA_CORTE', 'ANIO', 'NOM_MES', 'TOTAL_PAGANTES', 'TOTAL_NOPAGANTES', 'TOTAL']
df_selected3 = df[choose_headers3]

output_processed3 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed3.csv'

df_selected3.to_csv(output_processed3, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed3}')


# TODO: 4. Perfil del visitante tipico

# WARNING:Outcome: Perfiles demográficos y conductuales de los visitantes, que pueden usarse para diseñar experiencias personalizadas o estrategias de promoción.

        # TEST: ->NOM_TIPO
        # TEST: ->NOM_DPTO
        # TEST: ->NOM_MUSEO
        # TEST: ->ADU_BOLESPPAGANTES
        # TEST: ->EST_BOLESPPAGANTES
        # TEST: ->NIN_BOLESPPAGANTES
        # TEST: ->MIL_BOLESPPAGANTES
        # TEST: ->ADM_BOLESPPAGANTES
        # TEST: ->TOTAL_PAGANTES

choose_headers4 = ['NOM_TIPO', 'NOM_DPTO', 'NOM_MUSEO', 'ADU_BOLESPPAGANTES', 'EST_BOLESPPAGANTES', 'NIN_BOLESPPAGANTES', 'MIL_BOLESPPAGANTES', 'ADM_BOLESPPAGANTES', 'TOTAL_PAGANTES']
df_selected4 = df[choose_headers4]

output_processed4 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed4.csv'

df_selected4.to_csv(output_processed4, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed4}')


# TODO: 5. Comparativa entre regiones

# WARNING:Outcome: Un análisis geográfico que destaque las diferencias en la afluencia a museos entre departamentos.

        # TEST: ->NOM_DPTO
        # TEST: ->COD_DPTO
        # TEST: ->NOM_MUSEO
        # TEST: ->TOTAL_NOPAGANTES
        # TEST: ->TOTAL_PAGANTES 
        # TEST: ->TOTAL

choose_headers5 = ['NOM_DPTO', 'COD_DPTO', 'NOM_MUSEO', 'TOTAL_NOPAGANTES', 'TOTAL_PAGANTES', 'TOTAL']
df_selected5 = df[choose_headers5]

output_processed5 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed5.csv'

df_selected5.to_csv(output_processed5, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed5}')


# TODO: 6. Analisis de Ingresos(boletas pagadas vs boletas no pagadas)

# WARNING:Outcome: Comparativa detallada de ingresos por boletas pagadas y no pagadas, segmentada por museos y regiones

        # TEST: ->NOM_DPTO
        # TEST: ->NOM_MUSEO
        # TEST: ->NOM_TIPO
        # TEST: ->ADU_BOLESPPAGANTES
        # TEST: ->EST_BOLESPPAGANTES
        # TEST: ->NIN_BOLESPPAGANTES
        # TEST: ->MIL_BOLESPPAGANTES
        # TEST: ->ADM_BOLESPPAGANTES
        # TEST: ->ADU_BOLESPNOPAGANTES
        # TEST: ->EST_BOLESPNOPAGANTES
        # TEST: ->NIN_BOLESPNOPAGANTES
        # TEST: ->MIL_BOLESPNOPAGANTES
        # TEST: ->ADM_BOLESPNOPAGANTES

choose_headers6 = ['NOM_DPTO', 'NOM_MUSEO', 'NOM_TIPO', 'ADU_BOLESPPAGANTES', 'EST_BOLESPPAGANTES', 'NIN_BOLESPPAGANTES', 'MIL_BOLESPPAGANTES', 'ADM_BOLESPPAGANTES', 'ADU_BOLESPNOPAGANTES', 'EST_BOLESPNOPAGANTES', 'NIN_BOLESPNOPAGANTES', 'MIL_BOLESPNOPAGANTES', 'ADM_BOLESPNOPAGANTES']
df_selected6 = df[choose_headers6]

output_processed6 = r'R:\data_science\laboratory\projects\data_visitmuseos\data\processed\bd_5_processed6.csv'

df_selected6.to_csv(output_processed6, sep=';', index=False, encoding='latin1')

print(f'Archivo guardado en {output_processed6}')

