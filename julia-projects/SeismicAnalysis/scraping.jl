#NOTE: Version 1 sirve desde 2020 al 2026
# module Scraping

# using HTTP, JSON, DataFrames, CSV

# const IGP_URL = "https://ultimosismo.igp.gob.pe/api/ultimo-sismo/ajaxb"
# function fetch_sismos(year::Int)
#     url = "$(IGP_URL)/$(year)"
#     resp = HTTP.get(url)
#     data = JSON.parse(String(resp.body))
#     return DataFrame(data)
# end

# function save_sismos(year::Int; format="csv")
#     df = fetch_sismos(year)

#     for col in names(df)
#         df[!, col] = replace(df[!, col], nothing => missing)
#     end

#     mkpath("data")

#     if format == "csv"
#         CSV.write("data/sismos_$(year).csv", df)
#     else
#         open("data/sismos_$(year).json", "w") do f
#             write(f, JSON.json(df))
#         end
#     end

#     return df
# end
# end

# include("scraping.jl")
# using .Scraping
# df = Scraping.save_sismos(2026; format="csv")
#NOTE: Version 2 sirve desde 2019 hacia atrás

module Scraping

using HTTP, JSON, DataFrames, CSV

const IGP_URL = "https://ultimosismo.igp.gob.pe/api/ultimo-sismo/ajaxb"

function fetch_sismos(year::Int)
    url = "$(IGP_URL)/$(year)"
    resp = HTTP.get(url)
    raw = JSON.parse(String(resp.body))

    # Definir columnas esperadas
    rows = [
        (
            fecha = get(s, "fecha", missing),
            hora = get(s, "hora", missing),
            latitud = get(s, "latitud", missing),
            longitud = get(s, "longitud", missing),
            profundidad = get(s, "profundidad", missing),
            magnitud = get(s, "magnitud", missing),
            intensidad = get(s, "intensidad", missing),
            referencia = get(s, "referencia", missing),
            reporte_acelerometrico_pdf = get(s, "reporte_acelerometrico_pdf", missing)
        )
        for s in raw
    ]

    return DataFrame(rows)
end

function save_sismos(year::Int; format="csv")
    df = fetch_sismos(year)

    mkpath("data")

    if format == "csv"
        CSV.write("data/sismos_$(year).csv", df)
    else
        open("data/sismos_$(year).json", "w") do f
            write(f, JSON.json(df))
        end
    end

    return df
end

end
