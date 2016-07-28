defmodule Stats.ServerTest do
  use ExUnit.Case
  import Mock

  alias Stats.Server
  alias Stats.Backend.Stub

  doctest Stats.Server

  @notify_interval 200

  setup_all do
    Application.put_env(:stats, :notify_interval, @notify_interval, persistent: true)
    Application.put_env(:stats, :backends, [Stub], persistent: true)
    Application.start(:stats)

    on_exit fn ->
      :ok = Application.stop(:stats)
      :ok = Application.unload(:stats)
    end

    series = %Stats.Series{values: %{key: 42.42}}

    {:ok, %{series: series}}
  end

  setup do
    wait_sync
  end

  test "server saves to buffer", %{series: series} do
    Stats.notify(series)

    assert [%{values: %{key: 42.42}, timestamp: _, options: %{}}] = Server.buffer
  end

  test "server cleans buffer after notify_interval", %{series: series} do
    Stats.notify(series)

    assert [_|_] = Server.buffer

    wait_sync

    assert [] = Server.buffer
  end

  test "server sends to backends after notify_interval", %{series: series} do
    test_pid = self

    with_mock Stub, [notify_values: fn(values) -> send(test_pid, values) end] do
      Stats.notify(series)

      assert_receive [%{values: %{key: 42.42}, timestamp: _, options: %{}}], 500
      assert [] = Server.buffer
    end
  end

  defp wait_sync do
    :timer.sleep(@notify_interval)
  end
end
