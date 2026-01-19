# using Dash

# app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])

# app.layout = html_div() do
#     html_h1("Analysis for Seismic Data"),
#     html_div("Visualizing Seismic Activity Using Dash in Julia"),
#     dcc_graph(id = "example-graph",
#               figure = (
#                   data = [
#                       (x = [1, 2, 3], y = [4, 1, 2], type = "bar", name = "SF"),
#                       (x = [1, 2, 3], y = [2, 4, 5], type = "bar", name = "Montreal"),
#                   ],
#                   layout = (title = "Dash Data Visualization",)
#               ))
# end

# run_server(app)

#NOTE: http://127.0.0.1:8050



#NOTE: Version de Test
using GenieFramework
using DataFrames
using CSV
using PlotlyBase
using StipplePlotly
using Dates
using Unicode

# Intentar cargar Cairo si está disponible
HAS_CAIRO = false
try
    using Cairo
    global HAS_CAIRO = true
catch
    global HAS_CAIRO = false
end

function normalize_text(text::String)
    try
        normalized = Unicode.normalize(text, :NFD)
        return filter(c -> !(0x0300 <= Int(c) <= 0x036F), normalized)
    catch
        replacements = Dict(
            'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u',
            'Á' => 'A', 'É' => 'E', 'Í' => 'I', 'Ó' => 'O', 'Ú' => 'U',
            'ñ' => 'n', 'Ñ' => 'N',
            'ü' => 'u', 'Ü' => 'U'
        )
        result = ""
        for c in text
            result *= get(replacements, c, c)
        end
        return result
    end
end

@genietools

const FILE_PATH = joinpath("public", "uploads")
const EXPORT_PATH = joinpath("public", "exports")
mkpath(FILE_PATH)
mkpath(EXPORT_PATH)

@app begin
    @out title = "Análisis de Datos Sísmicos"
    @out upfiles = readdir(FILE_PATH)

    @in selected_file = ""
    @in selected_column = ""
    
    @in selected_reference = ""

    @in fileuploads = Dict{AbstractString, AbstractString}()
    @in rejected = Dict{AbstractString, AbstractString}()
    @in uploaded = Dict{AbstractString, AbstractString}()

    @out columns = String[]
    @out trace = [histogram()]
    
    @out reference_options = String[]
    
    @out filtered_table_data = DataTable()
    
    @out csv_download_url = ""
    @out pdf_download_url = ""
    
    @out analysis_uploaded_files = String[]
    
    @out analysis_loaded_datasets = Dict{String, DataFrame}()
    
    @out analysis_datasets_info = Dict{String, Dict}()
    
    @in analysis_fileuploads = Dict{AbstractString, AbstractString}()
    @in analysis_rejected = Dict{AbstractString, AbstractString}()
    
    @out analysis_selected_dataset = ""
    @out analysis_dataset_table = DataTable()
    
    @out analysis_dataset_rows = 0
    @out analysis_dataset_columns = 0
    @out analysis_dataset_size_mb = 0.0
    @out analysis_dataset_column_names = String[]

    @out table_data = DataTable()

    @out layout::PlotlyBase.Layout = PlotlyBase.Layout(
        yaxis_title_text = "Frecuencia",
        xaxis_title_text = "Valor"
    )

    @private data = DataFrame()
    @private filtered_data = DataFrame()

    @onchange fileuploads begin
        if !isempty(fileuploads)
            filename = fileuploads["name"]
            mv(fileuploads["path"], joinpath(FILE_PATH, filename), force = true)
            fileuploads = Dict{AbstractString, AbstractString}()
            upfiles = readdir(FILE_PATH)
            selected_file = filename
            notify(__model__, "Archivo listo para análisis")
        end
    end

    @onchange rejected begin
        notify(__model__, "Archivo no compatible")
    end

    @onchange isready, selected_file begin
        path = joinpath(FILE_PATH, selected_file)
        if isfile(path) && endswith(path, ".csv")
            try
                data = CSV.read(path, DataFrame)
                table_data = DataTable(data)
                columns = names(data)

                if !isempty(columns)
                    selected_column = columns[1]
                end
                
                if "referencia" in names(data)
                    reference_options = unique(skipmissing(data.referencia))
                    reference_options = sort(reference_options)
                else
                    reference_options = String[]
                end
            catch e
                notify(__model__, "Error al procesar CSV")
            end
        end
    end
    
    @onchange selected_reference begin
        if !isempty(selected_reference) && !isempty(data) && "referencia" in names(data)
            try
                accent_map = Dict(
                    'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u',
                    'Á' => 'A', 'É' => 'E', 'Í' => 'I', 'Ó' => 'O', 'Ú' => 'U',
                    'ñ' => 'n', 'Ñ' => 'N', 'ü' => 'u', 'Ü' => 'U'
                )
                
                function remove_accents_helper(txt::String)
                    try
                        return normalize_text(txt)
                    catch
                        result = ""
                        for ch in txt
                            result *= get(accent_map, ch, ch)
                        end
                        return result
                    end
                end
                
                ref_text = strip(String(selected_reference))
                words = split(ref_text)
                if !isempty(words)
                    last_word = replace(words[end], r"[^\w]" => "")
                    refneedle = lowercase(remove_accents_helper(last_word))
                else
                    refneedle = lowercase(remove_accents_helper(ref_text))
                end
                
                ref_cols = ["referencia", "referencia2", "referencia3"]
                ref_cols = [c for c in ref_cols if c in names(data)]
                
                filtered_data = filter(data) do row
                    any(ref_cols) do c
                        refval_raw = row[c]
                        if ismissing(refval_raw)
                            false
                        else
                            refval_str = string(refval_raw)
                            if isempty(refval_str)
                                false
                            else
                                refval = strip(refval_str)
                                refval_norm = try
                                    lowercase(normalize_text(refval))
                                catch
                                    result = ""
                                    for ch in refval
                                        result *= get(accent_map, ch, ch)
                                    end
                                    lowercase(result)
                                end
                                ref_words = split(refval_norm)
                                if !isempty(ref_words)
                                    ref_last_word = replace(ref_words[end], r"[^\w]" => "")
                                    ref_last_word == refneedle
                                else
                                    false
                                end
                            end
                        end
                    end
                end

                cols_to_show = ["referencia", "magnitud"]
                for col in ["fecha_local", "hora_local", "latitud", "longitud", "profundidad", "intensidad"]
                    if col in names(filtered_data)
                        push!(cols_to_show, col)
                    end
                end
                available_cols = [col for col in cols_to_show if col in names(filtered_data)]
                if !isempty(available_cols)
                    filtered_table_data = DataTable(filtered_data[:, available_cols])
                else
                    filtered_table_data = DataTable(filtered_data)
                end
            catch e
                notify(__model__, "Error al filtrar datos: $e")
                filtered_table_data = DataTable()
            end
        elseif isempty(selected_reference)
            filtered_table_data = DataTable()
        end
    end

    @onchange selected_column begin
        if !isempty(selected_column) && !isempty(data) && selected_column in names(data)
            trace = [histogram(x = data[!, selected_column])]
        end
    end
    
    @in export_csv_clicked = 0
    @onchange export_csv_clicked begin
        if export_csv_clicked > 0 && !isempty(filtered_data) && !isempty(selected_reference)
            try
                safe_ref = replace(selected_reference, r"[^\w\s-]" => "", r"\s+" => "_")
                filename = "sismos_$(safe_ref)_$(Dates.format(now(), "yyyy-mm-dd_HHMMSS")).csv"
                filepath = joinpath(EXPORT_PATH, filename)
                CSV.write(filepath, filtered_data)
                csv_download_url = "/exports/$filename"
                notify(__model__, "CSV exportado y descargando...")
                export_csv_clicked = 0
            catch e
                notify(__model__, "Error al exportar CSV: $e")
                export_csv_clicked = 0
            end
        end
    end
    
    @onchange csv_download_url begin
        if !isempty(csv_download_url)
        end
    end
    
    @in export_pdf_clicked = 0
    @onchange export_pdf_clicked begin
        if export_pdf_clicked > 0 && !isempty(filtered_data) && !isempty(selected_reference)
            try
                safe_ref = replace(selected_reference, r"[^\w\s-]" => "", r"\s+" => "_")
                filename = "sismos_$(safe_ref)_$(Dates.format(now(), "yyyy-mm-dd_HHMMSS")).pdf"
                filepath = joinpath(EXPORT_PATH, filename)
                
                if HAS_CAIRO
                    generate_pdf_table(filepath, filtered_data, selected_reference)
                    pdf_download_url = "/exports/$filename"
                    notify(__model__, "PDF exportado y descargando...")
                else
                    filename_csv = replace(filename, ".pdf" => ".csv")
                    filepath_csv = joinpath(EXPORT_PATH, filename_csv)
                    CSV.write(filepath_csv, filtered_data)
                    pdf_download_url = "/exports/$filename_csv"
                    notify(__model__, "Cairo no disponible. Exportado como CSV y descargando...")
                end
                export_pdf_clicked = 0
            catch e
                notify(__model__, "Error al exportar PDF: $e")
                export_pdf_clicked = 0
            end
        end
    end
    
    @onchange pdf_download_url begin
        if !isempty(pdf_download_url)
        end
    end
    
    @onchange isready begin
        analysis_upload_path = joinpath("public", "analysis_uploads")
        if isdir(analysis_upload_path)
            analysis_uploaded_files = filter(f -> endswith(f, ".csv"), readdir(analysis_upload_path))
        else
            mkpath(analysis_upload_path)
            analysis_uploaded_files = String[]
        end
    end
    
    @onchange analysis_fileuploads begin
        if !isempty(analysis_fileuploads)
            filename = analysis_fileuploads["name"]
            analysis_upload_path = joinpath("public", "analysis_uploads")
            mkpath(analysis_upload_path)
            dest_path = joinpath(analysis_upload_path, filename)
            
            mv(analysis_fileuploads["path"], dest_path, force = true)
            
            analysis_fileuploads = Dict{AbstractString, AbstractString}()
            
            analysis_uploaded_files = filter(f -> endswith(f, ".csv"), readdir(analysis_upload_path))
            
            notify(__model__, "Archivo cargado para análisis: $filename")
        end
    end
    
    @onchange analysis_rejected begin
        if !isempty(analysis_rejected)
            notify(__model__, "Error: Archivo rechazado. Verifique el formato.")
            analysis_rejected = Dict{AbstractString, AbstractString}()
        end
    end
    
    @onchange analysis_selected_dataset begin
        if !isempty(analysis_selected_dataset)
            analysis_upload_path = joinpath("public", "analysis_uploads")
            path = joinpath(analysis_upload_path, analysis_selected_dataset)
            if isfile(path) && endswith(path, ".csv")
                try
                    df = CSV.read(path, DataFrame)
                    analysis_loaded_datasets[analysis_selected_dataset] = df
                    
                    analysis_datasets_info[analysis_selected_dataset] = Dict(
                        "rows" => nrow(df),
                        "columns" => ncol(df),
                        "column_names" => string.(names(df)),
                        "size_mb" => round(filesize(path) / (1024 * 1024), digits=2)
                    )
                    
                    analysis_dataset_rows = nrow(df)
                    analysis_dataset_columns = ncol(df)
                    analysis_dataset_size_mb = round(filesize(path) / (1024 * 1024), digits=2)
                    analysis_dataset_column_names = string.(names(df))
                    
                    analysis_dataset_table = DataTable(df)
                    
                    notify(__model__, "Dataset cargado: $(nrow(df)) filas, $(ncol(df)) columnas")
                catch e
                    notify(__model__, "Error al leer el CSV: $e")
                    analysis_dataset_rows = 0
                    analysis_dataset_columns = 0
                    analysis_dataset_size_mb = 0.0
                    analysis_dataset_column_names = String[]
                    analysis_dataset_table = DataTable()
                end
            else
                analysis_dataset_rows = 0
                analysis_dataset_columns = 0
                analysis_dataset_size_mb = 0.0
                analysis_dataset_column_names = String[]
                analysis_dataset_table = DataTable()
            end
        else
            analysis_dataset_rows = 0
            analysis_dataset_columns = 0
            analysis_dataset_size_mb = 0.0
            analysis_dataset_column_names = String[]
            analysis_dataset_table = DataTable()
        end
    end
end

function generate_pdf_table(filepath::String, df::DataFrame, title::String)
    if !HAS_CAIRO
        error("Cairo no está disponible")
    end
    
    surface = Cairo.CairoPDFSurface(filepath, 800, 600)
    ctx = Cairo.CairoContext(surface)
    
    Cairo.set_font_size(ctx, 12)
    Cairo.select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
    
    Cairo.set_font_size(ctx, 16)
    Cairo.set_source_rgb(ctx, 0, 0, 0)
    Cairo.move_to(ctx, 50, 50)
    Cairo.show_text(ctx, title)
    
    Cairo.set_font_size(ctx, 10)
    Cairo.move_to(ctx, 50, 70)
    Cairo.show_text(ctx, "Total de registros: $(nrow(df))")
    Cairo.move_to(ctx, 50, 85)
    Cairo.show_text(ctx, "Fecha de exportación: $(Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))")
    
    y_start = 120
    x_start = 50
    col_width = 100
    row_height = 20
    
    Cairo.set_font_size(ctx, 10)
    Cairo.set_source_rgb(ctx, 0.2, 0.2, 0.8)
    
    x_pos = x_start
    for (i, col) in enumerate(names(df))
        if x_pos + col_width < 750  # Evitar desbordamiento
            Cairo.rectangle(ctx, x_pos, y_start, col_width, row_height)
            Cairo.set_source_rgb(ctx, 0.9, 0.9, 0.9)
            Cairo.fill(ctx)
            Cairo.set_source_rgb(ctx, 0, 0, 0)
            Cairo.move_to(ctx, x_pos + 5, y_start + 15)
            col_name = length(string(col)) > 12 ? string(col)[1:12] * "..." : string(col)
            Cairo.show_text(ctx, col_name)
            x_pos += col_width
        end
    end
    
    y_pos = y_start + row_height
    Cairo.set_font_size(ctx, 9)
    
    for (row_idx, row) in enumerate(eachrow(df))
        if y_pos > 550  # Nueva página si es necesario
            Cairo.show_page(ctx)
            y_pos = 50
        end
        
        x_pos = x_start
        for (col_idx, col) in enumerate(names(df))
            if x_pos + col_width < 750
                val = string(row[col])
                if length(val) > 15
                    val = val[1:15] * "..."
                end
                Cairo.set_source_rgb(ctx, 0, 0, 0)
                Cairo.move_to(ctx, x_pos + 5, y_pos + 15)
                Cairo.show_text(ctx, val)
                x_pos += col_width
            end
        end
        y_pos += row_height
    end
    
    Cairo.finish(surface)
    Cairo.destroy(surface)
end

using Genie.Router
using Genie.Renderer

route("/exports/:filename") do
    filename = params(:filename)
    filepath = joinpath(EXPORT_PATH, filename)
    if isfile(filepath)
        Genie.Renderer.respond(open(filepath), :file, filename=filename)
    else
        Genie.Renderer.respond("File not found", :not_found)
    end
end

@page("/", "ui.jl")
@page("/analysis", "analysis_ui.jl")
up(open_browser = true)
wait()
