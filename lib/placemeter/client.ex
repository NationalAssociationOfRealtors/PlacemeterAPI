defmodule Placemeter.Client do
    use HTTPoison.Base

    @token Application.get_env(:placemeter, :auth_token)
    @endpoint "https://api.placemeter.net/api/v1/"

    defmodule Point do
        @derive [Poison.Encoder]
        defstruct [:id, :name, :type, :location, :metrics, :classes, :data]
    end

    defmodule Location do
        @derive [Poison.Encoder]
        defstruct [:latitude, :longitude]
    end

    defmodule Metric do
        @derive [Poison.Encoder]
        defstruct [:name, :id]
    end


    def process_url(url) do
        IO.inspect @endpoint <> url
    end

    def process_request_headers(headers) do
        IO.inspect headers |> Dict.put(:"Authorization", "Token #{@token}")
    end

    def measurementpoints do
        case Placemeter.Client.get("measurementpoints") do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                {:ok, body
                    |> IO.inspect
                    |> Poison.decode!(as: [%Point{location: %Location{}, metrics: [%Metric{}], classes: []}])
                }
            {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
                {:error, body}
        end
    end

    def measurementpoints(point_id) do
        case Placemeter.Client.get("measurementpoints/#{point_id}") do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                {:ok, body
                    |> IO.inspect
                    |> Poison.decode!(as: %Point{location: %Location{}, metrics: [%Metric{}], classes: []})
                }
            {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
                {:error, body}
        end
    end

    def measurementpoints(point_id, start, en, res \\ "hour", metrics \\ "all") do
        case Placemeter.Client.get("measurementpoints/#{point_id}/data", [], params: %{start: start, "end": en, resolution: res, metrics: metrics}) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                {:ok, body
                    |> IO.inspect
                    |> Poison.Parser.parse!
                }
            {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
                {:error, body}
        end

    end

end
