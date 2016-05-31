defmodule Placemeter do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end

    def measurementpoints(time_ago \\ 1000) do
        GenServer.call(__MODULE__, {:measurementpoints, time_ago}, 10000)
    end

    def measurementpoint(id, time_ago \\ 1000) do
        GenServer.call(__MODULE__, {:measurementpoint, id, time_ago}, 10000)
    end

    def handle_call({:measurementpoints, time_ago}, _from, state) do
        case Placemeter.Client.measurementpoints do
            {:ok, response} ->
                {:reply, {:ok, Enum.map(response, &get_point(&1, time_ago))}, state}
            {:error, reason} ->
                {:reply, {:error, reason}, state}
        end
    end

    def handle_call({:measurementpoint, id, time_ago}, _from, state) do
        case Placemeter.Client.measurementpoints(id) do
            {:ok, response} ->
                {:reply, {:ok, get_point(response, time_ago)}, state}
            {:error, reason} ->
                {:reply, {:error, reason}, state}
        end
    end

    def get_point(point, time_ago) do
        IO.inspect point
        now = :erlang.system_time(:seconds)
        yesterday = now - time_ago
        case Placemeter.Client.measurementpoints(point.id, yesterday, now) do
            {:ok, %{"data" => data}} ->
                Enum.map(data, fn(record) -> %{:id => point.id, :data => record} end)
            {:error, reason} ->
                %{point | data: reason}
        end
    end

end
