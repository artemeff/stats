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

  test "server saves to buffer", %{series: series} do
    Stats.notify(series)

    assert [^series] = Server.buffer
  end

  test "server cleans buffer after notify_interval", %{series: series} do
    Stats.notify(series)

    assert [_|_] = Server.buffer

    wait_sync

    assert [] = Server.buffer
  end

  test "server sends to backends after notify_interval", %{series: series} do
    wait_sync

    with_mock Stub, [notify_values: fn(_values) -> :ok end] do
      Stats.notify(series)

      wait_sync

      assert called Stub.notify_values([series])
      assert [] = Server.buffer
    end
  end

  defp wait_sync do
    :timer.sleep(@notify_interval)
  end
end
