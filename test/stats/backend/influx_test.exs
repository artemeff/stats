defmodule Stats.Backend.InfluxTest do
  use ExUnit.Case

  alias Stats.{Server, Series}
  alias Stats.Backend.Influx

  doctest Stats.Backend.Influx

  @notify_interval 50
  @database "stats"
  @measurement "stats"

  setup_all do
    Application.put_env(:stats, :notify_interval, @notify_interval, persistent: true)
    Application.put_env(:stats, :backends, [Influx], persistent: true)
    Application.start(:stats)

    create_database(@database)

    on_exit fn ->
      drop_database(@database)

      :ok = Application.stop(:stats)
      :ok = Application.unload(:stats)
    end
  end

  test "saves keys to influxdb" do
    Server.notify(%Series{values: %{cpu: 1.1, mem: 1000}})
    Server.notify(%Series{values: %{cpu: 5.4, mem: 1100},
                          options: %{database: @database, table: @measurement,
                                     tags: %{test_tag: "test"}}})
    Server.notify(%Series{values: %{cpu: 1.9, mem: 1900}})

    :timer.sleep(100)

    result = get_measurements(@measurement, @database)

    %{results: [%{series: [series|_]}|_]} = result
    %{columns: columns, values: values} = series
    [[_time, cpu, mem, tag]|_] = values

    assert length(values) == 3
    assert length(columns) == 4
    assert cpu == 1.9
    assert mem == 1900
    assert tag == nil
  end

  defp get_measurements(name, db) do
    Influx.query("SELECT * FROM \"#{name}\"", database: db)
  end

  defp create_database(name) do
    "CREATE DATABASE \"#{name}\""
    |> Influx.execute(method: :post)
  end

  defp drop_database(name) do
    "DROP DATABASE \"#{name}\""
    |> Influx.execute(method: :post)
  end
end
