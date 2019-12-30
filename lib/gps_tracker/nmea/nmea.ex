defmodule GpsTracker.Nmea do
  @doc ~S"""
  Parses the given `line` GPS coordinates.

  ## Examples

      iex> GpsTracker.Nmea.parse("$GPGGA,064036.289,4836.53750,N,00740.93730,E,1,04,3.2,200.2,M,,,,0000*0E")
      {:ok, %{time: "064036.289", latitude: 48.60896, longitude: 7.68229}}

      iex> GpsTracker.Nmea.parse("$GPGGA,064036.289,,,,,,,,,,,,,0000*0E")
      {:error, %{message: "empty data", data: "$GPGGA,064036.289,,,,,,,,,,,,,0000*0E"}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,A,2503.63190,N,12136.00990,E,2.69,79.65,100106,,,A*53 ")
      {:ok, %{time: "053740.000", latitude: 25.06053, longitude: 121.60017}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,A,4740.57735,N,0311.51847,W,2.69,79.65,100106,,,A*53 ")
      {:ok, %{time: "053740.000", latitude: 47.67629, longitude: -3.19197}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,A,2503.63190,N,12136.00999,E,2.69,79.65,100106,,,A*53 ")
      {:ok, %{time: "053740.000", latitude: 25.06053, longitude: 121.60017}}

      iex> GpsTracker.Nmea.parse("$GPRMC,053740.000,V,,,,,,,,,,A*53")
      {:error, %{message: "empty data", data: "$GPRMC,053740.000,V,,,,,,,,,,A*53"}}

      iex> GpsTracker.Nmea.parse("bad data")
      {:error, %{message: "can't parse data", data: "bad data"}}
  """

  def parse(data) do
    data
    |> String.split(",")
    |> to_gps_struct()
  end

  defp to_gps_struct(
         [
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
         ] = data
       ) do
    with {:ok, latitude} <- to_degres("#{latitude},#{latitude_cardinal}"),
         {:ok, longitude} <- to_degres("#{longitude},#{longitude_cardinal}") do
      {:ok,
       %{
         time: time,
         latitude: latitude,
         longitude: longitude
       }}
    else
      {:error, %{message: "empty data"}} ->
        {:error, %{message: "empty data", data: Enum.join(data, ",")}}

      _ ->
        {:error, %{message: "can't parse data", data: Enum.join(data, ",")}}
    end
  end

  defp to_gps_struct(
         [
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
         ] = data
       ) do
    with {:ok, latitude} <- to_degres("#{latitude},#{latitude_cardinal}"),
         {:ok, longitude} <- to_degres("#{longitude},#{longitude_cardinal}") do
      {:ok,
       %{
         time: time,
         latitude: latitude,
         longitude: longitude
       }}
    else
      {:error, %{message: "empty data"}} ->
        {:error, %{message: "empty data", data: Enum.join(data, ",")}}

      _ ->
        {:error, %{message: "can't parse data", data: Enum.join(data, ",")}}
    end
  end

  defp to_gps_struct(data) do
    {:error, %{message: "can't parse data", data: Enum.join(data, ",")}}
  end

  @doc ~S"""
  Convert NMEA coordinates to DDS coordinates.

  ## Examples
      iex> GpsTracker.Nmea.to_degres("4902.63177,N")
      {:ok, 49.04386}

      iex> GpsTracker.Nmea.to_degres("00200.69856,E")
      {:ok, 2.01164}

      iex> GpsTracker.Nmea.to_degres("12136.69856,E")
      {:ok, 121.61164}

      iex> GpsTracker.Nmea.to_degres("4740.58920,N")
      {:ok, 47.67649}

      iex> GpsTracker.Nmea.to_degres("00200.69869,E")
      {:ok, 2.01164}

      iex> GpsTracker.Nmea.to_degres("4902.63175,S")
      {:ok, -49.04386}

      iex> GpsTracker.Nmea.to_degres("00200.69856,W")
      {:ok, -2.01164}
  """
  def to_degres(
        <<degres::bytes-size(2)>> <>
          <<minutes::bytes-size(8)>> <>
          <<_sep::bytes-size(1)>> <>
          <<cardinal::bytes-size(1)>>
      ) do
    {:ok, do_to_degres(degres, minutes, cardinal)}
  end

  def to_degres(
        <<degres::bytes-size(3)>> <>
          <<minutes::bytes-size(7)>> <>
          <<_sep::bytes-size(1)>> <>
          <<cardinal::bytes-size(1)>>
      ) do
    {:ok, do_to_degres(degres, minutes, cardinal)}
  end

  def to_degres(
        <<degres::bytes-size(3)>> <>
          <<minutes::bytes-size(8)>> <>
          <<_sep::bytes-size(1)>> <>
          <<cardinal::bytes-size(1)>>
      ) do
    {:ok, do_to_degres(degres, minutes, cardinal)}
  end

  def to_degres(",") do
    {:error, %{message: "empty data"}}
  end

  defp do_to_degres(degres, minutes, cardinal) do
    degres = degres |> float_parse()
    minutes = minutes |> float_parse()
    (degres + minutes / 60) |> Float.round(5) |> with_cardinal_orientation(cardinal)
  end

  defp with_cardinal_orientation(degres, cardinal) when cardinal in ["N", "E"] do
    degres
  end

  defp with_cardinal_orientation(degres, cardinal) when cardinal in ["S", "W"] do
    -degres
  end

  defp float_parse(value) do
    {value_parsed, _} = Float.parse(value)
    value_parsed
  end
end
