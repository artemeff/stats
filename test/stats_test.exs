defmodule StatsTest do
  use ExUnit.Case
  doctest Stats

  setup do
    on_exit fn ->
      :ok = Application.stop(:stats)
      :ok = Application.unload(:stats)
    end
  end

  test "start with empty backends" do
    assert start([]) == :ok
    assert [{Stats.Server, _, _, _}] = Supervisor.which_children(Stats.Supervisor)
  end

  test "start with stub backend" do
    assert start([Stats.Backend.Stub]) == :ok
    assert [{Stats.Server, _, _, _}] = Supervisor.which_children(Stats.Supervisor)
  end

  test "start with influx backend" do
    assert start([Stats.Backend.Influx]) == :ok
    assert [{Stats.Server, _, _, _},
            {Stats.Backend.Influx, _, _, _}] = Supervisor.which_children(Stats.Supervisor)
  end

  defp start(backends) do
    Application.put_env(:stats, :backends, backends, persistent: true)
    Application.start(:stats)
  end
end
