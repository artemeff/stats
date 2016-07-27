defmodule Stats do
  use Application

  defdelegate notify(values), to: Stats.Server

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Stats.Server, [])
    ]

    start_backends_deps(backends)

    opts = [strategy: :one_for_one, name: Stats.Supervisor]
    Supervisor.start_link(backends_spec(backends) ++ children, opts)
  end

  def backends do
    Application.get_env(:stats, :backends, [])
  end

  def default_database do
    Application.get_env(:stats, :default_database, "stats")
  end

  def default_table do
    Application.get_env(:stats, :default_table, "stats")
  end

  defp backends_spec(backends) do
    Enum.flat_map(backends, fn backend ->
      backend.supervisor_spec
    end)
  end

  defp start_backends_deps(backends) do
    Enum.each(backends, &start_backend_deps/1)
  end

  defp start_backend_deps(backend) do
    Enum.each(backend.application_deps, fn app ->
      {:ok, _} = Application.ensure_all_started(app)
    end)
  end
end
