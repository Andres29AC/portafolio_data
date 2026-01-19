# Mpox Data Explorer
La **Mpox** es una enfermedad infecciosa que se transmite a traves del contacto cercano con personas contagiosas o animales infectados. La mayoria de las personas se recuperan por completo, pero en algunos casos puede provocar una enfermedad grave o la muerte.
La vacunacion contra la viruela ofrece cierto grado de proteccion contra la viruela poliomieletica. La viruela fue erradicada en 1980 , por lo que las tasas de vacunacion contra esta enfermedad han disminuido desde entonces. Esto significa que la proteccion que brindaba contra la viruela poliomieletica ha disminuido, lo que ha provocado un aumento gradual de los casos en Africa occidental y central.
En mayo de 2022, un brote notable de mpox se extendio por todo el mundo. Este brote mundial se debido principalmente, pero no exclusivamente, a la transmision por contacto sexual entre hombres que tienen sexo con hombres. 2 La combinacion de campañas de salud publica, la disponibilidad de vacunas y las acciones de las comunidades afectadas dieron lugar a un menor numero de infecciones a nivel mundial.
Desde 2023, comenzo en Africa central una epidemia de una nueva variante de mpox, conocida como clado 1b. En agosto de 2024, la OMS declara este nuevo brote de mpox como una emergencia de salud publica de interes internacional. Sin embargo, la falta de infraestructura de diagnostico local significa que los casos sospechosos de mpox a menudo no se confirman.
## Objetivos del Proyecto
- **Analisis de Datos**: Investigar la propagacion de Mpox a traves del analisis de datos historicos.
- **Modelado Predictivo**: Desarrollar modelos para predecir futuros brotes de Mpox.
- **Visualizacion de Datos**: Crear visualizaciones que ayuden a comprender mejor los patrones de propagacion.

# Outcomes a analizar
## Tendencias temporales de casos y muertes
- **Outcomes:** total_cases, total_deaths,new_cases, new_deaths,new_cases_smoothed, new_deaths_smoothed
### Analisis:
- Visualización de la evolución diaria o semanal de nuevos casos y muertes.
- Comparación entre países/regiones para identificar diferencias en la velocidad de propagación
- Análisis de las tendencias suavizadas para observar patrones a largo plazo.
## Casos y muertes por millón de habitantes
- **Outcomes:** total_cases_per_million, total_deaths_per_million, new_cases_per_million, new_deaths_per_million,new_cases_smoothed_per_million, new_deaths_smoothed_per_million
### Analisis:
- Comparación de la incidencia ajustada por población entre diferentes países o regiones.
- Análisis de correlación entre casos y muertes per cápita para observar qué lugares son más vulnerables.
## Países o regiones con más impacto
- **Outcomes:** location,iso_code,total_cases,total_deaths
### Analisis:
- Identificación de los países/regiones con el mayor número de casos y muertes acumulados.
- Ranking de países según los casos y muertes totales, ajustados por población.
- Mapas de calor o gráficos para visualizar el impacto geográfico.
## Casos sospechosos (cumulative suspected cases)
- **Outcomes:** suspected_cases_cumulative
### Analisis:
- Análisis del número de casos sospechosos reportados para entender si existe un subregistro o si la detección fue insuficiente.
- Comparar países con altos casos sospechosos y cómo varía en relación con los casos confirmados.
## Comparación de curvas de mortalidad y casos
- **Outcomes:** total_cases, total_deaths,new_cases,new_deaths 
### Analisis:
- Comparar la relación entre el número de casos y el número de muertes a lo largo del tiempo para calcular la tasa de mortalidad en diferentes regiones.
- Evaluar cómo esta relación cambia con la progresión de la enfermedad y si existen picos en la mortalidad en ciertas fechas o regiones.

