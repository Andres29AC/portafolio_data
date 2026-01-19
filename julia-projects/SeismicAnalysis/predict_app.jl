# Precisión del Modelo:
# El sistema logró un RMSE de 0.26, lo que significa que las
# predicciones tienen un margen de error mínimo, validando la
# elección de la Regresión Lineal sobre modelos más complejos
# para este volumen de datos.
# Influencia Geográfica:
# Gracias al análisis de coeficientes, se determinó que la Longitud
# es el predictor más fuerte. Esto coincide con la realidad sismológica,
# donde la distancia a la zona de subducción es crítica.
# Ciclo Completo:
# Se logró integrar con éxito el procesamiento de datos científicos
# en Julia con una interfaz de usuario moderna y funcional, permitiendo
# que un modelo técnico sea accesible para cualquier persona.

using Dash, PlotlyJS, DataFrames, Dates, Serialization, MLJ, MLJLinearModels, DotEnv

const ENV_PATH = joinpath(@__DIR__, ".env")
if isfile(ENV_PATH)
    DotEnv.config(ENV_PATH)
    # Refuerzo manual para inyectar al diccionario ENV
    for line in eachline(ENV_PATH)
        if contains(line, "=") && !startswith(line, "#")
            k, v = split(line, "=", limit=2)
            ENV[strip(k)] = strip(replace(v, "\"" => "", "'" => ""))
        end
    end
end

include("gemini_service.jl")

const MODEL_PATH = joinpath("models", "best_seismic_model.jls")
const best_machine = deserialize(MODEL_PATH)

app = dash()

style_input = Dict("width" => "100%", "padding" => "12px", "borderRadius" => "8px", "border" => "1px solid #cbd5e1", "marginTop" => "5px", "fontSize" => "16px")
style_label = Dict("fontWeight" => "600", "color" => "#334155", "marginTop" => "20px", "display" => "block")

app.layout = html_div(style=Dict("backgroundColor" => "#f1f5f9", "minHeight" => "100vh", "padding" => "40px"), [
    html_div(style=Dict("maxWidth" => "900px", "margin" => "auto"), [

        html_div([
            html_h1("🌎 Predicción Sísmica Áncash", style=Dict("textAlign"=>"center", "color"=>"#1e3a8a", "fontWeight"=>"900")),
            html_p("Simulador con Análisis Tectónico", style=Dict("textAlign"=>"center", "color"=>"#475569"))
        ], style=Dict("marginBottom"=>"30px")),

        html_div([
            html_div([
                html_div([
                    html_label("Latitud", style=style_label),
                    dcc_input(id="lat", type="number", value=-9.5, step=0.01, style=style_input),
                    html_label("Longitud", style=style_label),
                    dcc_input(id="lon", type="number", value=-77.5, step=0.01, style=style_input),
                ], style=Dict("width" => "48%", "display" => "inline-block")),
                html_div([
                    html_label("Profundidad (km)", style=style_label),
                    dcc_input(id="depth", type="number", value=30, step=1, style=style_input),
                    html_label("Fecha (AAAA-MM-DD)", style=style_label),
                    dcc_input(id="date-input", type="text", value=string(today()), style=style_input),
                ], style=Dict("width" => "48%", "display" => "inline-block", "float" => "right")),
            ], style=Dict("overflow" => "hidden")),

            html_div([
                html_button("🔮 Predecir y Analizar con IA", id="predict-btn", n_clicks=0,
                    style=Dict("backgroundColor"=>"#2563eb", "color"=>"white", "padding"=>"15px", "borderRadius"=>"10px", "width"=>"70%", "fontWeight"=>"bold", "cursor"=>"pointer")),
                html_button("🧹 Limpiar", id="reset-btn", n_clicks=0,
                    style=Dict("backgroundColor"=>"white", "color"=>"#64748b", "width"=>"25%", "borderRadius"=>"10px", "border"=>"1px solid #e2e8f0", "cursor"=>"pointer"))
            ], style=Dict("display"=>"flex", "justifyContent"=>"space-between", "marginTop"=>"40px"))
        ], style=Dict("backgroundColor"=>"white", "padding"=>"40px", "borderRadius"=>"24px", "boxShadow"=>"0 10px 20px rgba(0,0,0,0.05)")),

        dcc_loading(id="loading", type="circle", children=[
            html_div(id="prediction-output", style=Dict("marginTop" => "30px")),
            html_div(id="map-output", style=Dict("marginTop" => "20px")),
            html_div(id="ia-output", style=Dict("marginTop" => "20px"))
        ])
    ])
])

callback!(app,
    Output("lat", "value"), Output("lon", "value"), Output("depth", "value"), Output("date-input", "value"),
    Input("reset-btn", "n_clicks")
) do n; return -9.5, -77.5, 30, string(today()) end

callback!(app,
    Output("prediction-output", "children"),
    Output("map-output", "children"),
    Output("ia-output", "children"),
    Input("predict-btn", "n_clicks"),
    State("lat", "value"), State("lon", "value"), State("depth", "value"), State("date-input", "value")
) do n, lat, lon, depth, date_str
    if n == 0 return nothing, nothing, nothing end

    try
        dt = parse(Date, strip(date_str))
        Xnew = DataFrame(lat=[Float64(lat)], lon=[Float64(lon)], depth=[Float64(depth)],
                         year=[Int64(year(dt))], month=[Int64(month(dt))], day=[Int64(day(dt))])

        # Predicción
        y_pred = predict(best_machine, Xnew)
        mag = round(y_pred[1], digits=2)
        color = mag < 4.5 ? "#10b981" : mag < 5.5 ? "#f59e0b" : "#ef4444"

        # Mapa (USO DE OPEN-STREET-MAP PARA EVITAR ERRORES)
        p_map = plot(
            scattermapbox(lat=[lat], lon=[lon], mode="markers", marker=attr(size=20, color="red", symbol="star")),
            Layout(
                mapbox=attr(style="open-street-map", center=attr(lat=lat, lon=lon), zoom=7),
                height=350, margin=attr(l=0,r=0,t=0,b=0)
            )
        )

        # Análisis IA
        texto_ia = obtener_analisis_geologico(mag, lat, lon, depth)

        res_ui = html_div([
            html_h2("$mag Mw", style=Dict("color"=>color, "fontSize"=>"55px", "fontWeight"=>"900", "textAlign"=>"center")),
            html_p("Basado en el histórico de la región Áncash", style=Dict("textAlign"=>"center", "fontSize"=>"18px", "fontStyle"=>"italic"))
        ], style=Dict("backgroundColor"=>"white", "padding"=>"30px", "borderRadius"=>"20px", "border"=>"2px solid $color"))

        ia_ui = html_div([
            html_h4("🕵️ Informe Geológico IA", style=Dict("color"=>"#1e3a8a", "marginBottom"=>"15px")),
            dcc_markdown(texto_ia)
        ], style=Dict("backgroundColor"=>"white", "padding"=>"30px", "borderRadius"=>"20px", "boxShadow"=>"0 4px 6px rgba(0,0,0,0.05)"))

        return res_ui, dcc_graph(figure=p_map), ia_ui
    catch e
        @error "Error en el procesamiento" exception=(e, catch_backtrace())
        return html_div("⚠️ Datos Inválidos o Error de Conexión", style=Dict("color"=>"red", "textAlign"=>"center")), nothing, nothing
    end
end

run_server(app, "127.0.0.1", 8050, debug=true)
