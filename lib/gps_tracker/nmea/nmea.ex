defmodule GpsTracker.Nmea do
  @doc ~S"""
  Parses the given `line` GPS coordinates.

  ## Examples

      iex> GpsTracker.Nmea.parse("$GPGGA,064036.289,4836.5375,N,00740.9373,E,1,04,3.2,200.2,M,,,,0000*0E")
      {:ok, %{time: "064036.289", latitude: 48.608958333333, longitude: 7.682288333333}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,A,2503.6319,N,12136.0099,E,2.69,79.65,100106,,,A*53 ")
      {:ok, %{time: "053740.000", latitude: 25.060531666667, longitude: 121.600165}}

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
         _type,
         _nb_satellites,
         _precision,
         _altitude,
         _altitude_unit,
         _,
         _,
         _,
         _sig
       ]) do
    {:ok,
     %{
       time: time,
       latitude: to_degres("#{latitude},#{latitude_cardinal}"),
       longitude: to_degres("#{longitude},#{longitude_cardinal}")
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
         _speed,
         _,
         _,
         _,
         _,
         _sig
       ]) do
    {:ok,
     %{
       time: time,
       latitude: to_degres("#{latitude},#{latitude_cardinal}"),
       longitude: to_degres("#{longitude},#{longitude_cardinal}")
     }}
  end

  defp to_gps_struct(data) do
    {:error, %{message: "can't parse data", data: Enum.join(data, ",")}}
  end

  @doc ~S"""
  Convert NMEA coordinates to DDS coordinates.

  ## Examples
      iex> GpsTracker.Nmea.to_degres("4902.6317,N")
      49.043861666667

      iex> GpsTracker.Nmea.to_degres("00200.6986,E")
      2.011643333333

      iex> GpsTracker.Nmea.to_degres("4902.6317,S")
      -49.043861666667

      iex> GpsTracker.Nmea.to_degres("00200.6986,O")
      -2.011643333333
  """
  def to_degres(
        <<degres::bytes-size(2)>> <>
          <<minutes::bytes-size(7)>> <>
          <<_sep::bytes-size(1)>> <>
          <<cardinal::bytes-size(1)>>
      ) do
    do_to_degres(degres, minutes, cardinal)
  end

  def to_degres(
        <<degres::bytes-size(3)>> <>
          <<minutes::bytes-size(7)>> <>
          <<_sep::bytes-size(1)>> <>
          <<cardinal::bytes-size(1)>>
      ) do
    do_to_degres(degres, minutes, cardinal)
  end

  defp do_to_degres(degres, minutes, cardinal) do
    degres = degres |> float_parse()
    minutes = minutes |> float_parse()
    (degres + minutes / 60) |> Float.round(12) |> with_cardinal_orientation(cardinal)
  end

  defp with_cardinal_orientation(degres, cardinal) when cardinal in ["N", "E"] do
    degres
  end

  defp with_cardinal_orientation(degres, cardinal) when cardinal in ["S", "O"] do
    -degres
  end

  defp float_parse(value) do
    {value_parsed, _} = Float.parse(value)
    value_parsed
  end
end
