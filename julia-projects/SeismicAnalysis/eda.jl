#Gráfico de Dispersión: Profundidad vs Magnitud
# Concentración Superficial: La gran nube de puntos está
# entre los 10 km y 50 km. Esto significa que la mayoría
# de los sismos en Áncash son superficiales, los cuales
# suelen sentirse con más fuerza en la superficie.
# Eventos aislados: Hay algunos puntos a la derecha (más
# de 120 km). Estos son sismos profundos, probablemente
# asociados a la placa de Nazca hundiéndose bajo el
# continente.
# El "Outlier" (Punto destacado): Hay un punto amarillo
# brillante arriba, cerca de los 50 km de profundidad
# con magnitud 6.0. Ese es el evento más crítico de tu
# dataset y el que deberías mencionar como el sismo de
# mayor impacto.

#Nuestro dashboard revela que, aunque los sismos ocurren
#de manera constante, el año 2025 fue el más activo. La
#mayoría de los eventos son de magnitud moderada (alrededor
#de 4.1) y ocurren a poca profundidad (menos de 50 km),
#lo cual es característico de la zona costera y andina de
#Áncash. El evento más significativo registrado alcanzó
#una magnitud de 6.0, destacándose claramente sobre el
#promedio habitual.

using Dash
using PlotlyJS
using CSV
using DataFrames
using Statistics
using Dates

df = CSV.read("data/clean/ancash_clean.csv", DataFrame)

if eltype(df.datetime) <: AbstractString
    df.datetime = [parse(DateTime, replace(string(s), "T" => " ")) for s in df.datetime]
end

df.year = year.(df.datetime)
df.month = month.(df.datetime)

meses_nombres = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
df_base_meses = DataFrame(month = 1:12, nombre_mes = meses_nombres)

years = sort(unique(df.year))
mag_classes = sort(unique(df.mag_class))
depth_classes = sort(unique(df.depth_class))

#NOTE: Estilos de UI
card_style = Dict(
    "backgroundColor" => "white",
    "padding" => "25px",
    "borderRadius" => "15px",
    "boxShadow" => "0 4px 12px rgba(0,0,0,0.08)",
    "margin" => "20px 0px"
)

app = dash()

app.layout = html_div(style=Dict("backgroundColor" => "#f4f7f9", "padding" => "40px", "fontFamily" => "Segoe UI, sans-serif"), [

    html_h1("🏠 Monitor Sísmico - Región Áncash",
        style=Dict("textAlign" => "left", "color" => "#1e3a8a", "fontWeight" => "800", "marginBottom" => "10px")),

    html_p("Análisis detallado de actividad sísmica basado en filtros personalizados.",
        style=Dict("color" => "#64748b", "marginBottom" => "30px")),

    html_div(style=card_style, [
        html_div([
            html_div([
                html_label("📅 Año", style=Dict("fontWeight" => "bold", "color" => "#334155")),
                dcc_dropdown(id="year-filter", options=[Dict("label"=>string(y), "value"=>y) for y in years], value=[years[end]], multi=true)
            ], style=Dict("width"=>"32%", "display"=>"inline-block")),

            html_div([
                html_label("📈 Magnitud", style=Dict("fontWeight" => "bold", "color" => "#334155")),
                dcc_dropdown(id="mag-filter", options=[Dict("label"=>m, "value"=>m) for m in mag_classes], value=mag_classes, multi=true)
            ], style=Dict("width"=>"32%", "display"=>"inline-block", "marginLeft" => "2%")),

            html_div([
                html_label("🌊 Profundidad", style=Dict("fontWeight" => "bold", "color" => "#334155")),
                dcc_dropdown(id="depth-filter", options=[Dict("label"=>d, "value"=>d) for d in depth_classes], value=depth_classes, multi=true)
            ], style=Dict("width"=>"32%", "display"=>"inline-block", "marginLeft" => "2%"))
        ])
    ]),

    html_div(id="kpi-container", style=Dict("display"=>"flex", "justifyContent"=>"space-between", "gap" => "20px")),

    html_div([
        html_div(style=card_style, [dcc_graph(id="month-bars")]),
        html_div(style=card_style, [dcc_graph(id="timeline")]),
        html_div(style=card_style, [dcc_graph(id="magnitude-hist")]),
        html_div(style=card_style, [dcc_graph(id="depth-vs-mag")])
    ])
])

callback!(
    app,
    Output("kpi-container", "children"),
    Output("month-bars", "figure"),
    Output("timeline", "figure"),
    Output("magnitude-hist", "figure"),
    Output("depth-vs-mag", "figure"),
    Input("year-filter", "value"),
    Input("mag-filter", "value"),
    Input("depth-filter", "value")
) do years_sel, mag_sel, depth_sel

    df_f = filter(row -> row.year in years_sel && row.mag_class in mag_sel && row.depth_class in depth_sel, df)

    if isempty(df_f)
        vacio = plot(Layout(title="No hay datos con los filtros actuales"))
        return html_div("Sin datos"), vacio, vacio, vacio, vacio
    end

    #NOTE: KPIs
    total_sismos = nrow(df_f)
    max_mag = maximum(df_f.mag)
    avg_depth = round(mean(df_f.depth), digits=2)

    kpis = [
        html_div([html_h4("Sismos Registrados", style=Dict("margin"=>"0")), html_h2(string(total_sismos), style=Dict("color"=>"#2563eb", "margin"=>"10px 0"))], style=merge(card_style, Dict("flex"=>"1", "textAlign"=>"center", "margin"=>"0"))),
        html_div([html_h4("Mayor Magnitud", style=Dict("margin"=>"0")), html_h2(string(max_mag), style=Dict("color"=>"#dc2626", "margin"=>"10px 0"))], style=merge(card_style, Dict("flex"=>"1", "textAlign"=>"center", "margin"=>"0"))),
        html_div([html_h4("Profundidad Media", style=Dict("margin"=>"0")), html_h2("$avg_depth km", style=Dict("color"=>"#059669", "margin"=>"10px 0"))], style=merge(card_style, Dict("flex"=>"1", "textAlign"=>"center", "margin"=>"0")))
    ]

    #NOTE: Meses (Azul)
    df_month_counts = combine(groupby(df_f, :month), nrow => :count)
    df_plot_month = leftjoin(df_base_meses, df_month_counts, on=:month)
    df_plot_month.count = coalesce.(df_plot_month.count, 0)

    p_month = plot(df_plot_month, x=:nombre_mes, y=:count, kind="bar",
        marker=attr(color="#3b82f6"),
        Layout(title_text="📅 Cantidad de Sismos por Mes", xaxis_title="Mes", yaxis_title="Total",
               xaxis=attr(categoryorder="array", categoryarray=meses_nombres), height=450))

    #NOTE: Línea de tiempo (Amarillo/Naranja)
    df_year_counts = combine(groupby(df_f, :year), nrow => :count)
    p_line = plot(df_year_counts, x=:year, y=:count, mode="lines+markers",
        line=attr(color="#f59e0b", width=4), marker=attr(size=12, color="#d97706"),
        Layout(title_text="📉 Evolución Sísmica Anual", height=400))

    #NOTE: Histograma (Morado)
    p_hist = plot(df_f, x=:mag, kind="histogram",
        marker_color="#8b5cf6",
        Layout(title_text="📊 Distribución por Magnitud (Mw)", xaxis_title="Magnitud", height=400))

    #NOTE: Scatter (Multicolor Viridis)
    p_scat = plot(df_f, x=:depth, y=:mag, mode="markers",
        marker=attr(color=:mag, colorscale="Viridis", showscale=true, size=10, opacity=0.7),
        Layout(title_text="📍 Correlación: Profundidad vs Magnitud", xaxis_title="Profundidad (km)", yaxis_title="Magnitud", height=500))

    return kpis, p_month, p_line, p_hist, p_scat
end

run_server(app, "127.0.0.1", 8050, debug=true)
