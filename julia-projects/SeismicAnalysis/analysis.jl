#Proyecto: Análisis y Predicción de Sismos en Áncash (2020–2026)
# Transform(ETL) - limpieza y preparación de datos
#NOTE: Limpieza de datos
using CSV
using DataFrames
using Dates
using Statistics
using Parquet

raw_path = "data/export"
clean_path = "data/clean"
enriched_path = "data/enriched"

mkpath(clean_path)
mkpath(enriched_path)

println("Cargando archivos...")
files = filter(f -> endswith(f, ".csv"), readdir(raw_path, join=true))

if isempty(files)
    error("No se encontraron archivos CSV en $raw_path")
end

df_raw = vcat([CSV.read(f, DataFrame, stringtype=String) for f in files]...)

rename!(df_raw, Dict(
    "latitud" => "lat",
    "longitud" => "lon",
    "magnitud" => "mag",
    "profundidad" => "depth"
    # 'referencia' se mantiene con su nombre original
))

function combine_datetime(date_val, time_val)
    try
        if ismissing(date_val) || ismissing(time_val) return nothing end

        d_str = split(string(date_val), 'T')[1]

        t_full = split(string(time_val), 'T')
        if length(t_full) < 2 return nothing end
        t_str = split(t_full[2], '.')[1]

        return DateTime(d_str * " " * t_str, dateformat"yyyy-mm-dd HH:MM:SS")
    catch
        return nothing
    end
end

println("Procesando transformaciones...")
df_raw.datetime = combine_datetime.(df_raw.fecha_utc, df_raw.hora_utc)

filter!(r -> !isnothing(r.datetime), df_raw)

safe_f(x) = x isa Number ? Float64(x) : parse(Float64, string(x))

df_raw.lat = safe_f.(df_raw.lat)
df_raw.lon = safe_f.(df_raw.lon)
df_raw.mag = safe_f.(df_raw.mag)
df_raw.depth = safe_f.(df_raw.depth)

filter!(r ->
    -12.5 <= r.lat <= -7.5 &&
    -80.5 <= r.lon <= -76.5 &&
    r.mag > 0,
    df_raw
)

if nrow(df_raw) > 0
    df_raw.year = year.(df_raw.datetime)
    df_raw.month = month.(df_raw.datetime)
    df_raw.day = day.(df_raw.datetime)
    df_raw.hour = hour.(df_raw.datetime)

    df_raw.mag_class = [m < 3 ? "micro" : m < 4 ? "leve" : m < 5 ? "moderado" : "fuerte" for m in df_raw.mag]

    df_raw.depth_class = [d < 70 ? "superficial" : d < 300 ? "intermedia" : "profunda" for d in df_raw.depth]

    df_raw.energy = 10.0 .^ (1.5 .* df_raw.mag .+ 4.8)

    sort!(df_raw, :datetime)

    df_final = DataFrame(
        datetime = string.(df_raw.datetime),
        lat = Float64.(df_raw.lat),
        lon = Float64.(df_raw.lon),
        mag = Float64.(df_raw.mag),
        depth = Float64.(df_raw.depth),
        referencia = String.(df_raw.referencia),
        year = Int64.(df_raw.year),
        month = Int64.(df_raw.month),
        day = Int64.(df_raw.day),
        hour = Int64.(df_raw.hour),
        mag_class = String.(df_raw.mag_class),
        depth_class = String.(df_raw.depth_class),
        energy = Float64.(df_raw.energy)
    )

    CSV.write(joinpath(clean_path, "ancash_clean.csv"), df_final)
    write_parquet(joinpath(enriched_path, "ancash_enriched.parquet"), df_final)

    println("--- RESULTADOS FINALES ---")
    println("✅ Proceso completado exitosamente.")
    println("📍 Registros procesados: ", nrow(df_final))
    println("📅 Rango temporal: $(first(df_final.datetime)) a $(last(df_final.datetime))")
    println("📂 Archivos guardados en '$clean_path' y '$enriched_path'")
else
    println("⚠️ El proceso terminó pero no quedaron registros tras aplicar los filtros.")
end
