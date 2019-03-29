defmodule GpsTracker.Nmea do
  @doc ~S"""
  Parses the given `line` GPS coordinates.

  ## Examples

      iex> GpsTracker.Nmea.parse("$GPGGA,064036.289,4836.5375,N,00740.9373,E,1,04,3.2,200.2,M,,,,0000*0E")
      {:ok, %{time: "064036.289", latitude: "4836.5375,N",longitude: "00740.9373,E", type: "1", nb_satellites: "04", hdop: "3.2", altitude: "200.2,M"}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,A,2503.6319,N,12136.0099,E,2.69,79.65,100106,,,A*53 ")
      {:ok, %{time: "053740.000", latitude: "2503.6319,N",longitude: "12136.0099,E", speed: "2.69"}}

      iex> GpsTracker.Nmea.parse("bad data")
      {:error, %{message: "can't parse data", data: "bad data"}}
  """

  def parse(data) do
    data
    |> String.split(",")
    |> to_gps_struct()
  end

  defp to_gps_struct([
         "$GPGGA",
         time,
         latitude,
         latitude_cardinal,
         longitude,
         longitude_cardinal,
         type,
         nb_satellites,
         precision,
         altitude,
         altitude_unit,
         _,
         _,
         _,
         _sig
       ]) do
    {:ok,
     %{
       time: time,
       latitude: "#{latitude},#{latitude_cardinal}",
       longitude: "#{longitude},#{longitude_cardinal}",
       type: type,
       nb_satellites: nb_satellites,
       hdop: precision,
       altitude: "#{altitude},#{altitude_unit}"
     }}
  end

  defp to_gps_struct([
         "$GPRMC",
         time,
         _data_state,
         latitude,
         latitude_cardinal,
         longitude,
         longitude_cardinal,
         speed,
         _,
         _,
         _,
         _,
         _sig
       ]) do
    {:ok,
     %{
       time: time,
       latitude: "#{latitude},#{latitude_cardinal}",
       longitude: "#{longitude},#{longitude_cardinal}",
       speed: speed
     }}
  end

  defp to_gps_struct(data) do
    {:error, %{message: "can't parse data", data: Enum.join(data, ",")}}
  end
end
