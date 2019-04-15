defmodule GpsTracker.DataFetcher do
  use GenServer

  alias GpsTracker.Transpondeur

  @doc """
  Start the fetcher and open communication with GPS card.
  """
  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  GenServer.init/1 callback
  """
  def init(state) do
    [{uart, nil}] = Registry.lookup(GpsTracker.Registry, "uart")
    Circuits.UART.configure(uart, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    Circuits.UART.open(uart, "ttyAMA0", speed: 9600, active: true)

    {:ok, state}
  end

  def handle_info({:circuits_uart, _port, data}, state) do
    state =
      case GpsTracker.Nmea.parse(data) do
        {:ok, position} -> position
        {:error, _} -> state
      end

    {:noreply, state}
  end

  def version do
    "1.0"
  end
end
