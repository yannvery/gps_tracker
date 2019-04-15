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

  @impl true
  def init(endpoint) do
    {:ok, endpoint}
  end

  @impl true
  def handle_cast({:emit, position}, endpoint) do
    {:ok, json} = Poison.encode(position)

    HTTPoison.post(endpoint, "{\"body\": #{json}}", [
      {"Content-Type", "application/json"}
    ])

    {:noreply, endpoint}
  end
end