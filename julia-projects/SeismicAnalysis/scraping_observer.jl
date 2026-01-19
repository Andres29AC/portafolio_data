module ScrapingObserver

using HTTP, JSON, DataFrames

const IGP_URL = "https://ultimosismo.igp.gob.pe/api/ultimo-sismo/ajaxb/2026"
const STATE = Ref(DataFrame())

function fetch_sismos()
    resp = HTTP.get(IGP_URL)
    data = JSON.parse(String(resp.body))
    df = DataFrame(data)

    for col in names(df)
        df[!, col] = replace(df[!, col], nothing => missing)
    end

    return df
end

function check_updates!()
    new_df = fetch_sismos()

    if isempty(STATE[]) || nrow(new_df) > nrow(STATE[])
        STATE[] = new_df
    end

    return STATE[]
end

function get_state()
    STATE[]
end

end
