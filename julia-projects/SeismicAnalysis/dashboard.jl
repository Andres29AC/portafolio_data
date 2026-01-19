#NOTE: Version Gozu
using Dash
using DataFrames
using CSV
using Dates

include("scraping_observer.jl")
using .ScrapingObserver: check_updates!

app = dash(external_stylesheets=[
    "https://codepen.io/chriddyp/pen/bWLwgP.css"
])

const CARDS_PER_PAGE = 8

function sismo_card(row)
    raw_mag = row[:magnitud]
    mag = typeof(raw_mag) <: Number ? Float64(raw_mag) : parse(Float64, string(raw_mag))

    fecha_raw = string(row[:fecha_local])
    hora_raw = string(row[:hora_local])

    fecha_limpia = length(fecha_raw) >= 10 ? fecha_raw[1:10] : fecha_raw

    hora_limpia = contains(hora_raw, "T") ? split(hora_raw, "T")[2][1:8] :
                  (length(hora_raw) >= 8 ? hora_raw[1:8] : hora_raw)

    color_mag = mag >= 5.0 ? "#d32f2f" : "#2e7d32"

    Dash.html_div(
        className="four columns",
        style=Dict(
            "padding" => "15px",
            "margin" => "10px 0",
            "border" => "1px solid #ddd",
            "border-left" => "5px solid $color_mag", # Resalte lateral de color
            "border-radius" => "8px",
            "box-shadow" => "0 2px 4px rgba(0,0,0,0.1)",
            "min-height" => "200px",
            "background-color" => "white"
        ),
        children=[
            Dash.html_h4("M $mag", style=Dict("color" => color_mag, "font-weight" => "bold")),
            Dash.html_p([Dash.html_strong("Fecha: "), fecha_limpia]),
            Dash.html_p([Dash.html_strong("Hora: "), hora_limpia]),
            Dash.html_p([Dash.html_strong("Profundidad: "), "$(row[:profundidad]) km"]),
            Dash.html_p(Dash.html_small(row[:referencia]), style=Dict("color" => "#666", "line-height" => "1.2"))
        ]
    )
end

app.layout = Dash.html_div(style=Dict("padding" => "20px", "background-color" => "#f4f7f6", "min-height" => "100vh")) do
    [
        Dash.html_h2("Observador Sísmico IGP 2026", style=Dict("text-align"=>"center", "margin-bottom" => "30px")),

        Dash.html_div(style=Dict("display"=>"flex", "justify-content"=>"center", "gap"=>"10px", "margin-bottom"=>"20px")) do
            [
                Dash.html_button("Actualizar", id="btn", className="button-primary"),
                Dash.html_button("Exportar CSV", id="btn_csv"),
                Dash.html_span("", id="csv_msg", style=Dict("align-self"=>"center", "margin-left"=>"10px", "color" => "green"))
            ]
        end,

        Dash.html_div(id="cards", className="row"),

        Dash.html_div(style=Dict("display"=>"flex", "justify-content"=>"center", "align-items"=>"center", "gap"=>"20px", "margin-top"=>"30px")) do
            [
                Dash.html_button("« Anterior", id="prev_page"),
                Dash.html_div(id="page_info", style=Dict("font-weight"=>"bold")),
                Dash.html_button("Siguiente »", id="next_page")
            ]
        end,

        Dash.dcc_store(id="page_store", data=1)
    ]
end

Dash.callback!(
    app,
    [
        Dash.Output("cards", "children"),
        Dash.Output("page_info", "children"),
        Dash.Output("page_store", "data")
    ],
    [
        Dash.Input("btn", "n_clicks"),
        Dash.Input("prev_page", "n_clicks"),
        Dash.Input("next_page", "n_clicks")
    ],
    [Dash.State("page_store", "data")]
) do btn_click, prev_click, next_click, current_page

    df = check_updates!()
    if isnothing(df) || isempty(df)
        return (Dash.html_div("No se encontraron sismos."), "Página 0 de 0", 1)
    end

    sort!(df, [:fecha_local, :hora_local], rev=true)

    ctx = Dash.callback_context()
    total_pages = max(ceil(Int, nrow(df) / CARDS_PER_PAGE), 1)

    new_page = current_page
    if !isempty(ctx.triggered)
        trigger_id = split(ctx.triggered[1].prop_id, ".")[1]

        if trigger_id == "prev_page"
            new_page = max(current_page - 1, 1)
        elseif trigger_id == "next_page"
            new_page = min(current_page + 1, total_pages)
        elseif trigger_id == "btn"
            new_page = 1
        end
    end

    start_idx = (new_page - 1) * CARDS_PER_PAGE + 1
    end_idx = min(new_page * CARDS_PER_PAGE, nrow(df))

    cards_layout = [sismo_card(row) for row in eachrow(df[start_idx:end_idx, :])]
    page_text = "Página $new_page de $total_pages"

    return (cards_layout, page_text, new_page)
end

Dash.callback!(
    app,
    Dash.Output("csv_msg", "children"),
    Dash.Input("btn_csv", "n_clicks"),
    prevent_initial_call=true
) do n_clicks
    (isnothing(n_clicks) || n_clicks == 0) && return ""
    df = check_updates!()

    home = get(ENV, "USERPROFILE", get(ENV, "HOME", "."))
    path = joinpath(home, "Downloads", "sismos_exportados.csv")

    try
        CSV.write(path, df)
        return "✓ Exportado a Descargas"
    catch
        return "Error al exportar"
    end
end

Dash.run_server(app, "0.0.0.0", 8050, debug=true)
