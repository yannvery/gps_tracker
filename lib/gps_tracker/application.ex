defmodule GpsTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: GpsTracker.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  def children(_target) do
    [
      {Registry, [keys: :unique, name: GpsTracker.Registry]},
      {Circuits.UART, [name: {:via, Registry, {GpsTracker.Registry, "uart"}}]},
      {GpsTracker.DataFetcher, []}
    ]
  end
end
