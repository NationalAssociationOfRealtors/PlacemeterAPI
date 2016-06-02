defmodule PlacemeterTest do
    use ExUnit.Case
    require Logger
    doctest Placemeter

    test "the truth" do
        assert 1 + 1 == 2
    end

    test "placemeter returns data" do
        token = Application.get_env(:placemeter, :auth_token)
        IO.inspect token
        {:ok, pm} = Placemeter.start_link(token)
        case Placemeter.measurementpoints(pm) do
            {:ok, data} ->
                IO.inspect data
            {anything, data} ->
                IO.inspect anything
                IO.inspect data
        end
    end
end
