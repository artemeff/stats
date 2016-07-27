defmodule Stats.Backend do
  @callback application_deps() :: [atom]
  @callback supervisor_spec() :: [Supervisor.Spec.spec]
  @callback notify_values([%Stats.Series{}]) :: :ok
end
