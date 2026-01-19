import pandas as pd
import matplotlib.pyplot as plt

# Cargar datos
df_outcome1 = pd.read_csv('R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome1_clean.csv')
columns_interest_outcome1 = ['date', 'total_cases', 'total_deaths', 'new_cases', 'new_deaths', 'new_cases_smoothed', 'new_deaths_smoothed']
df_capture = df_outcome1[columns_interest_outcome1]

# Convertir la columna 'date' a formato de fecha
df_capture['date'] = pd.to_datetime(df_capture['date'])

# Agrupar por fecha para obtener la suma diaria de casos y muertes
daily_cases = df_capture.groupby('date')['new_cases'].sum()
daily_deaths = df_capture.groupby('date')['new_deaths'].sum()
smoothed_cases = df_capture.groupby('date')['new_cases_smoothed'].sum()
smoothed_deaths = df_capture.groupby('date')['new_deaths_smoothed'].sum()

# Crear la figura con dos subgráficos
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10), sharex=True)

# Gráfico sin tendencias suavizadas
ax1.plot(daily_cases, label='Nuevos Casos', color='blue')
ax1.plot(daily_deaths, label='Nuevas Muertes', color='red')
ax1.set_yscale('log')
ax1.set_title('Evolución diaria de nuevos casos y nuevas muertes (sin suavizar)')
ax1.set_ylabel('Cantidad')
ax1.legend()
ax1.grid(True)

# Gráfico con tendencias suavizadas
ax2.plot(daily_cases, label='Nuevos Casos', color='blue', alpha=0.4)
ax2.plot(daily_deaths, label='Nuevas Muertes', color='red', alpha=0.4)
ax2.plot(smoothed_cases, label='Casos Suavizados', color='blue', linestyle='--', linewidth=2)
ax2.plot(smoothed_deaths, label='Muertes Suavizadas', color='red', linestyle='--', linewidth=2)
ax2.set_yscale('log')
ax2.set_title('Evolución diaria de nuevos casos y nuevas muertes (con suavizado)')
ax2.set_xlabel('Fecha')
ax2.set_ylabel('Cantidad')
ax2.legend()
ax2.grid(True)

# Mostrar el gráfico
plt.tight_layout()
plt.show()


"""
Datos Diarios (Opacos):
Las barras azul y roja, con menor opacidad, muestran nuevamente los datos de
nuevos casos y muertes diarias, como en el gráfico superior.
Líneas de Tendencia Suavizadas:
La línea azul punteada representa los casos diarios suavizados (new_cases_smoothed)
proporcionando una visión más estable de la tendencia general de los casos a lo largo del tiempo.
La línea roja punteada representa las muertes diarias suavizadas (new_deaths_smoothed),
permitiendo una observación más clara de la tendencia general en los datos de mortalidad.
Escala Logarítmica en el Eje y:
También se utiliza una escala logarítmica para facilitar la comparación entre valores bajos y altos.
Interpretación:
Las líneas de tendencia suavizadas eliminan gran parte de la volatilidad diaria y muestran un patrón más 
claro y continuo en el tiempo. En el caso de los casos, se puede observar un pico en algún punto alrededor 
de 2022-07 y una disminución posterior hasta 2023.
La tendencia de muertes parece ser más baja en comparación con los casos, pero se mantiene relativamente 
constante con algunos picos visibles.
"""


#
# import matplotlib.pyplot as plt
# from mpl_toolkits.mplot3d import Axes3D
# import pandas as pd
# import matplotlib.dates as mdates
#
# # Cargar y procesar datos
# df_outcome1 = pd.read_csv('R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome1_clean.csv')
# df_outcome1['date'] = pd.to_datetime(df_outcome1['date'])
# df_outcome1.set_index('date', inplace=True)
#
# # Extraer los datos necesarios
# dates = df_outcome1.index
# new_cases = df_outcome1['new_cases']
# new_deaths = df_outcome1['new_deaths']
#
# # Convertir fechas a números
# date_numbers = mdates.date2num(dates)
#
# # Crear gráfico 3D
# fig = plt.figure(figsize=(10, 7))
# ax = fig.add_subplot(111, projection='3d')
#
# # Gráfico de dispersión 3D
# ax.plot(date_numbers, new_cases, new_deaths, color='blue', label='Casos y Muertes Diarios')
#
# # Configurar etiquetas
# ax.set_xlabel('Fecha')
# ax.set_ylabel('Nuevos Casos')
# ax.set_zlabel('Nuevas Muertes')
# ax.set_title('Evolución de nuevos casos y muertes en 3D')
#
# # Formato de fecha en el eje X
# ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
# fig.autofmt_xdate()  # Rotar etiquetas de fecha para mejor visibilidad
#
# # Ajuste de leyenda y mostrar
# ax.legend()
# plt.show()



#
# import plotly.graph_objects as go
# import pandas as pd
#
# # Cargar y procesar datos
# df_outcome1 = pd.read_csv('R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome1_clean.csv')
# df_outcome1['date'] = pd.to_datetime(df_outcome1['date'])
#
# # Extraer los datos necesarios
# dates = df_outcome1['date']
# new_cases = df_outcome1['new_cases']
# new_deaths = df_outcome1['new_deaths']
#
# # Crear gráfico 3D
# fig = go.Figure(data=[go.Scatter3d(
#     x=dates,                # Eje de fechas
#     y=new_cases,            # Eje de nuevos casos
#     z=new_deaths,           # Eje de nuevas muertes
#     mode='markers+lines',   # Opciones de estilo
#     marker=dict(
#         size=5,
#         color=new_cases,    # Color basado en el valor de 'new_cases'
#         colorscale='Viridis', # Colores para distinguir valores
#         opacity=0.8
#     )
# )])
#
# # Configurar diseño
# fig.update_layout(
#     title="Evolución de nuevos casos y muertes en 3D",
#     scene=dict(
#         xaxis=dict(title='Fecha'),
#         yaxis=dict(title='Nuevos Casos'),
#         zaxis=dict(title='Nuevas Muertes')
#     ),
#     template="plotly_white"
# )
#
# # Mostrar gráfico
# fig.show()




# import pandas as pd
# import plotly.graph_objects as go
# from plotly.subplots import make_subplots
#
# # Cargar datos
# df_outcome1 = pd.read_csv('R:/data_science/laboratory/projects/mpox_data_explorer/data/processed/outcome1_clean.csv')
# columns_interest_outcome1 = ['date', 'total_cases', 'total_deaths', 'new_cases', 'new_deaths', 'new_cases_smoothed', 'new_deaths_smoothed']
# df_capture = df_outcome1[columns_interest_outcome1]
#
# # Convertir la columna 'date' a formato de fecha
# df_capture['date'] = pd.to_datetime(df_capture['date'])
#
# # Agrupar por fecha para obtener la suma diaria de casos y muertes
# daily_cases = df_capture.groupby('date')['new_cases'].sum()
# daily_deaths = df_capture.groupby('date')['new_deaths'].sum()
# smoothed_cases = df_capture.groupby('date')['new_cases_smoothed'].sum()
# smoothed_deaths = df_capture.groupby('date')['new_deaths_smoothed'].sum()
#
# # Crear la figura con dos subgráficos
# fig = make_subplots(rows=2, cols=1, shared_xaxes=True, 
#                     subplot_titles=('Evolución diaria de nuevos casos y nuevas muertes (sin suavizar)', 
#                                     'Evolución diaria de nuevos casos y nuevas muertes (con suavizado)'),
#                     vertical_spacing=0.1)
#
# # Primer gráfico: sin suavizado
# fig.add_trace(go.Scatter(x=daily_cases.index, y=daily_cases, mode='lines', name='Nuevos Casos', line=dict(color='blue')), row=1, col=1)
# fig.add_trace(go.Scatter(x=daily_deaths.index, y=daily_deaths, mode='lines', name='Nuevas Muertes', line=dict(color='red')), row=1, col=1)
#
# # Segundo gráfico: con suavizado
# fig.add_trace(go.Scatter(x=daily_cases.index, y=daily_cases, mode='lines', name='Nuevos Casos', line=dict(color='blue'), opacity=0.4), row=2, col=1)
# fig.add_trace(go.Scatter(x=daily_deaths.index, y=daily_deaths, mode='lines', name='Nuevas Muertes', line=dict(color='red'), opacity=0.4), row=2, col=1)
# fig.add_trace(go.Scatter(x=smoothed_cases.index, y=smoothed_cases, mode='lines', name='Casos Suavizados', line=dict(color='blue', dash='dash', width=2)), row=2, col=1)
# fig.add_trace(go.Scatter(x=smoothed_deaths.index, y=smoothed_deaths, mode='lines', name='Muertes Suavizadas', line=dict(color='red', dash='dash', width=2)), row=2, col=1)
#
# # Ajustes de diseño
# fig.update_layout(
#     title='Evolución de Nuevos Casos y Muertes',
#     xaxis_title='Fecha',
#     yaxis_title='Cantidad',
#     yaxis2=dict(title='Cantidad', type='log'),
#     showlegend=True,
#     template='plotly_dark'
# )
#
# # Mostrar gráfico
# fig.show()
