defmodule GpsTracker.DataFetcher do
  use GenServer

  alias GpsTracker.Transpondeur

  @doc """
  Retrieve the pid of the started process
  """
  def pid() do
    GenServer.call(__MODULE__, :pid)
  end

  @doc """
  Start the fetcher and open communication with GPS card.
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    [{uart, nil}] = Registry.lookup(GpsTracker.Registry, "uart")
    Circuits.UART.configure(uart, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    Circuits.UART.open(uart, "ttyAMA0", speed: 9600, active: true)

    {:ok, %{current_position: nil}}
  end

  @impl true
  def handle_info({:circuits_uart, port, data}, state) do
    receive_data({:circuits_uart, port, data}, state)
  end

  def receive_data({:circuits_uart, _port, data}, state) do
    state =
      case GpsTracker.Nmea.parse(data) do
        {:ok, position} ->
          Transpondeur.emit(position)
          %{current_position: position}

        _ ->
          state
      end

    {:noreply, state}
  end

  @impl true
  def handle_call(:pid, _from, state) do
    {:reply, self(), state}
  end
end
