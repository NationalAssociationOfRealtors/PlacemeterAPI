defmodule Placemeter.Client do
    use HTTPoison.Base

    @endpoint "https://api.placemeter.net/api/v1/"

    defmodule Point do
        defstruct [:id, :name, :type, :location, :metrics, :classes, :data]
    end

    defmodule Location do
        defstruct [:latitude, :longitude]
    end

    defmodule Metric do
        defstruct [:name, :id]
    end

    def process_url(url) do
        @endpoint <> url
    end

    defp call(url, token, parameters \\ %{}) do
        case Placemeter.Client.get(url, Dict.put([], :"Authorization", "Token #{token}"), params: parameters) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                {:ok, body}
            {:ok, %HTTPoison.Response{body: body, status_code: status_code}} when status_code > 400 ->
                {:error, body}
            {:error, reason} ->
                {:error, reason}
        end
    end

    def measurementpoints(token) do
        case call("measurementpoints", token) do
            {:ok, body} ->
                {:ok, body |> Poison.decode!(as: [%Point{location: %Location{}, metrics: [%Metric{}], classes: []}])}
            {:error, body} ->
                {:error, body}
        end
    end

    def measurementpoints(token, point_id) do
        case call("measurementpoints/#{point_id}", token) do
            {:ok, body} ->
                {:ok, body |> Poison.decode!(as: %Point{location: %Location{}, metrics: [%Metric{}], classes: []})}
            {:error, body} ->
                {:error, body}
        end
    end

    def measurementpoints(token, point_id, start, en, res \\ "minute", metrics \\ "all", classes \\ "all") do
        case call("measurementpoints/#{point_id}/data", token, %{start: start, "end": en, resolution: res, classes: classes}) do
            {:ok, body} ->
                {:ok, body |> Poison.Parser.parse!}
            {:error, body} ->
                {:error, body}
        end

    end

end
