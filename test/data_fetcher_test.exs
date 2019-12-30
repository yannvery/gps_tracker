defmodule GpsTracker.DataFetcherTest do
  use ExUnit.Case
  doctest GpsTracker.DataFetcher

  describe "handle_info :circuits_art" do
    test "invalid data" do
      response = GpsTracker.DataFetcher.receive_data({:circuits_uart, nil, ""}, %{})
      assert response == {:noreply, %{}}
    end

    test "with valid data" do
      data = "$GPRMC,053740.000,A,2503.63190,N,12136.00999,E,2.69,79.65,100106,,,A*53"
      response = GpsTracker.DataFetcher.receive_data({:circuits_uart, nil, data}, %{})

      assert response ==
               {:noreply,
                %{
                  current_position: %{
                    latitude: 25.06053,
                    longitude: 121.60017,
                    time: "053740.000"
                  }
                }}
    end

    test "with valid current position" do
      data = "$GPRMC,053740.000,A,2503.63190,N,12136.00999,E,2.69,79.65,100106,,,A*53"

      response =
        GpsTracker.DataFetcher.receive_data({:circuits_uart, nil, data}, %{
          current_position: %{
            latitude: 25.06053,
            longitude: 121.60017,
            time: "053740.000"
          }
        })

      assert response ==
               {:noreply,
                %{
                  current_position: %{
                    latitude: 25.06053,
                    longitude: 121.60017,
                    time: "053740.000"
                  }
                }}
    end

    test "with valid current position and a distance > 5 meters" do
      data = "$GPRMC,053740.000,A,2503.63190,N,12136.00999,E,2.69,79.65,100106,,,A*53"

      response =
        GpsTracker.DataFetcher.receive_data({:circuits_uart, nil, data}, %{
          current_position: %{
            latitude: 25.06053,
            longitude: 121.60027,
            time: "053740.000"
          }
        })

      assert response ==
               {:noreply,
                %{
                  current_position: %{
                    latitude: 25.06053,
                    longitude: 121.60017,
                    time: "053740.000"
                  }
                }}
    end
  end
end
