defmodule GpsTracker.Transpondeur do
  use GenServer

  @doc """
  Start the Transpondeur.
  """
  def start_link(endpoint) do
    GenServer.start_link(__MODULE__, endpoint, name: __MODULE__)
  end

  @doc """
  Emit a position to an endpoint.
  """
  def emit(coordinates) do
    GenServer.cast(__MODULE__, {:emit, coordinates})
  end

  @doc """
  Retrieve the pid of the started process
  """
  def pid() do
    GenServer.call(__MODULE__, :pid)
  end

  @impl true
  def init(endpoint) do
    {:ok, %{endpoint: endpoint, current_position: nil}}
  end

  @impl true
  def handle_cast(
        {:emit, position},
        state = %{endpoint: endpoint, current_position: nil}
      ) do
    {:ok, json} = Poison.encode(position)
    post_to(endpoint, json)

    {:noreply, %{state | current_position: position}}
  end

  def handle_cast(
        {:emit, position},
        state = %{endpoint: endpoint, current_position: current_position}
      ) do
    with true <- position_issued_after?(position, current_position),
         {:ok, distance} <- GpsTracker.Distance.compute(position, current_position),
         {:ok, distance_in_meters} <- GpsTracker.Distance.to_meters(distance),
         true <- distance_in_meters > 5.0 do
      post_to(endpoint, position)
      {:noreply, %{state | current_position: position}}
    else
      _ ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call(:pid, _from, state) do
    {:reply, self(), state}
  end

  def position_issued_after?(position, current_position) do
    with {position_time, ""} <- Float.parse(Map.get(position, :time, "0")),
         {current_position_time, ""} <- Float.parse(Map.get(current_position, :time, "0")) do
      position_time > current_position_time
    end
  end

  defp post_to(endpoint, position) do
    {:ok, json} = Poison.encode(position)

    HTTPotion.post(endpoint,
      body: json,
      headers: ["User-Agent": "My App", "Content-Type": "application/json"]
    )
  end
end
