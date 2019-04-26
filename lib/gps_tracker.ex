defmodule GpsTracker do
  @moduledoc """
  Documentation for GpsTracker.
  """

  def start_debug_uart do
    [{uart, nil}] = Registry.lookup(GpsTracker.Registry, "uart")
    :sys.trace(uart, true)
  end

  def stop_debug_uart do
    [{uart, nil}] = Registry.lookup(GpsTracker.Registry, "uart")
    :sys.trace(uart, false)
  end

  def start_debug_fetcher do
    pid = GpsTracker.DataFetcher.pid()
    :sys.trace(pid, true)
  end

  def stop_debug_fetcher do
    pid = GpsTracker.DataFetcher.pid()
    :sys.trace(pid, false)
  end

  def start_debug_transpondeur do
    pid = GpsTracker.Transpondeur.pid()
    :sys.trace(pid, true)
  end

  def stop_debug_transpondeur do
    pid = GpsTracker.Transpondeur.pid()
    :sys.trace(pid, false)
  end
end
