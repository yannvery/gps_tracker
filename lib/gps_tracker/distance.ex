defmodule GpsTracker.Distance do
  @doc ~S"""
  Computes a distance between 2 coordinates

  ## Examples

      iex> GpsTracker.Distance.compute(%{latitude: 5, longitude: 5}, %{latitude: 5, longitude: 5})
      {:ok, 0.0}

      iex> GpsTracker.Distance.compute(%{latitude: 5, longitude: 4}, %{latitude: 5, longitude: 5})
      {:ok, 1.0}

      iex> GpsTracker.Distance.compute(%{latitude: 4, longitude: 4}, %{latitude: 5, longitude: 5})
      {:ok, 1.41422}

      iex> GpsTracker.Distance.compute(%{latitude: 48.856667, longitude: 2.350987}, %{latitude: 45.767299, longitude: 4.834329})
      {:ok, 3.96374}

      iex> GpsTracker.Distance.compute(%{latitude: 49.054911, longitude: 2.019176}, %{latitude: 49.054961, longitude: 2.019062})
      {:ok, 1.3e-4}
  """
  def compute(%{longitude: x1, latitude: y1}, %{longitude: x2, latitude: y2}) do
    distance =
      (:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2))
      |> :math.sqrt()
      |> Float.ceil(5)

    {:ok, distance}
  end

  def compute(_pos1, _pos2), do: :error

  @doc ~S"""
  1 degree equals to 111.319km
  This is a naive implementation for short distance

  ## Examples

    iex> GpsTracker.Distance.to_meters(1)
    {:ok, 111_319.0}

    iex> GpsTracker.Distance.to_meters(3.963733357377613)
    {:ok, 441238.83361}

    iex> GpsTracker.Distance.to_meters(1.2448293055738208e-4)
    {:ok, 13.85732}
  """
  def to_meters(distance) do
    distance_in_meters = (distance * 111_319.0) |> Float.ceil(5)
    {:ok, distance_in_meters}
  end
end
