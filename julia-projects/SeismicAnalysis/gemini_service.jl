#https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$api_key

using HTTP, JSON

function obtener_analisis_geologico(mag, lat, lon, depth)
    api_key = get(ENV, "GEMINI_API_KEY", "")

    if isempty(api_key)
        return "❌ Error: API Key no encontrada en el entorno."
    end

    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$api_key"

    prompt = """
    Actúa como un asistente técnico de análisis sísmico basado en datos históricos.
    El valor de magnitud proporcionado es una predicción estadística generada por un modelo de Machine Learning,
    no un evento sísmico real ni un boletín oficial.

    Con base en estos datos estimados:
    - Magnitud estimada: $mag Mw
    - Profundidad: $depth km
    - Ubicación: Latitud $lat, Longitud $lon (Referencia: Áncash)

    Proporciona un análisis interpretativo y educativo, no oficial, indicando:
    1. Percepción probable de manera orientativa.
    2. Contexto tectónico general del Perú.
    3. Relación aproximada con estructuras geológicas conocidas.

    Incluye una advertencia de que el análisis no representa evaluación de riesgo ni reporte oficial.
    """

    body = JSON.json(Dict(
        "contents" => [Dict(
            "parts" => [Dict("text" => prompt)]
        )]
    ))

    try
        response = HTTP.post(url,
                             ["Content-Type" => "application/json"],
                             body,
                             connect_timeout=30)

        data = JSON.parse(String(response.body))

        # Validación segura de la respuesta
        if haskey(data, "candidates") && !isempty(data["candidates"])
            candidate = data["candidates"][1]
            if haskey(candidate, "content") && haskey(candidate["content"], "parts")
                return candidate["content"]["parts"][1]["text"]
            end
        end

        return "⚠️ La API respondió pero el formato de contenido fue inesperado."

    catch e
        @error "Fallo en la llamada a Gemini" exception=e
        return "⚠️ Error de conexión o parámetros: No se pudo obtener el análisis."
    end
end
