defmodule Stats.Backend.Stub do
  @behaviour Stats.Backend

  def application_deps do
    []
  end

  def supervisor_spec do
    []
  end

  def notify_values(_values) do
    :ok
  end
end
