using CSV
using DataFrames
using Dates
using Statistics
using Random
using Glob
using MLJ
using MLJLinearModels
using MLJDecisionTreeInterface
using Serialization

DATA_DIR = "data/clean/"
files = sort(glob("ancash_*.csv", DATA_DIR))

if isempty(files)
    error("No se encontraron archivos CSV en $DATA_DIR")
end

println("Archivos detectados: ", files)
data = CSV.read(files[1], DataFrame)
println("\nTotal registros: ", nrow(data))

#NOTE: Aseguramos que datetime sea tipo DateTime
if eltype(data.datetime) <: AbstractString
    data.datetime = [parse(DateTime, replace(string(s), "T" => " ")) for s in data.datetime]
end

#NOTE: Extraemos componentes temporales
data.year  = year.(data.datetime)
data.month = month.(data.datetime)
data.day   = day.(data.datetime)

#NOTE: Selección de variables para el modelo (Target: mag)
#NOTE: Usamos nombres de columnas de tu Fase 2 (lat, lon, depth, mag)
select!(data, [:lat, :lon, :depth, :year, :month, :day, :mag])
dropmissing!(data)

println("Datos listos para ML. Dimensiones: ", size(data))

#NOTE: Particionamiento de datos
y = data.mag
X = select(data, Not(:mag))

Random.seed!(123)
train, test = partition(eachindex(y), 0.8, shuffle=true)

Xtrain, ytrain = X[train, :], y[train]
Xtest, ytest = X[test, :], y[test]

#NOTE: Mdelo 1: Regresión Lineal
println("\nEntrenando Regresión Lineal...")
LinearRegressor = @load LinearRegressor pkg=MLJLinearModels
lin_model = LinearRegressor()
lin_machine = machine(lin_model, Xtrain, ytrain)
fit!(lin_machine)

yhat_lin = predict(lin_machine, Xtest)
rmse_lin = rmse(yhat_lin, ytest)
println("RMSE Regresión Lineal: ", round(rmse_lin, digits=4))

#NOTE: Modelo 2: Árbol de Decisión
println("Entrenando Árbol de Decisión...")
DecisionTreeRegressor = @load DecisionTreeRegressor pkg=DecisionTree
tree_model = DecisionTreeRegressor(max_depth = 5, min_samples_leaf = 5)
tree_machine = machine(tree_model, Xtrain, ytrain)
fit!(tree_machine)

yhat_tree = predict(tree_machine, Xtest)
rmse_tree = rmse(yhat_tree, ytest)
println("RMSE Árbol de Decisión: ", round(rmse_tree, digits=4))

#NOTE: Comparación de modelos
println("\n----------------------------------")
println("    RESULTADOS DE LA FASE 4")
println("----------------------------------")

best_machine = nothing

if rmse_tree < rmse_lin
    println("GANADOR: Árbol de Decisión")
    best_machine = tree_machine
else
    println("GANADOR: Regresión Lineal")
    best_machine = lin_machine
end

#NOTE: Guardar el modelo ganador para uso futuro
MODEL_DIR = "models"
mkpath(MODEL_DIR)
MODEL_PATH = joinpath(MODEL_DIR, "best_seismic_model.jls")

serialize(MODEL_PATH, best_machine)
println("\n✅ Modelo ganador guardado en: $MODEL_PATH")

#NOTE: Lógica corregida para extraer coeficientes numéricos de los Pares de MLJLinearModels
if best_machine.model isa LinearRegressor
    println("\n--- COEFICIENTES DEL MODELO (IMPORTANCIA) ---")
    params = fitted_params(best_machine)

    # params.coefs devuelve una lista de Pares (:variable => valor)
    v_nombres = [p.first for p in params.coefs]
    v_valores = [p.second for p in params.coefs]

    importance_df = DataFrame(
        variable = v_nombres,
        coeficiente = v_valores,
        impacto_abs = abs.(v_valores)
    )

    sort!(importance_df, :impacto_abs, rev=true)
    println(importance_df)

    CSV.write(joinpath(MODEL_DIR, "feature_importance.csv"), importance_df)
    println("\nIntercepto (Base): ", round(params.intercept, digits=4))
end

println("\n--- FASE 4 COMPLETADA CON ÉXITO ---")
