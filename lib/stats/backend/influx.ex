defmodule Stats.Backend.Influx do
  @behaviour Stats.Backend

  use Instream.Connection, otp_app: :stats

  def application_deps do
    [:instream]
  end

  def supervisor_spec do
    [child_spec]
  end

  def notify_values([]) do
    :ok
  end
  def notify_values(values) do
    values = Enum.map(values, &from_series/1)

    # FIXME batch writing
    Enum.each(values, fn value ->
      write(value, async: true)
    end)
  end

  # FIXME list of points from values
  defp from_series(%Stats.Series{values: fields, options: options, timestamp: timestamp} = series) do
    %{
      database: Map.get(options, :database, Stats.default_database),
      points: [points(fields, timestamp, options)]
    }
  end

  defp points(fields, timestamp, options) do
    %{
      measurement: Map.get(options, :table, Stats.default_table),
      fields:      fields,
      tags:        Map.get(options, :tags, %{}),
      timestamp:   timestamp
    }
  end
end
