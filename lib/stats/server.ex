defmodule Stats.Server do
  defstruct buffer: []

  use GenServer

  # public api

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def notify(values) do
    GenServer.cast(__MODULE__, {:notify, values})
  end

  def buffer do
    GenServer.call(__MODULE__, :buffer)
  end

  # gen_server callbacks

  def init(_) do
    start_timer
    {:ok, %Stats.Server{}}
  end

  def handle_call(:buffer, _from, %{buffer: buffer} = state) do
    {:reply, buffer, state}
  end
  def handle_call(_, _, state) do
    {:noreply, state}
  end

  def handle_cast({:notify, values}, %{buffer: buffer} = state) do
    values = assign_timestamp(values)
    {:noreply, %{state|buffer: [values|buffer]}}
  end
  def handle_cast(_, state) do
    {:noreply, state}
  end

  def handle_info(:save, %{buffer: buffer} = state) do
    Enum.each(Stats.backends, fn backend ->
      backend.notify_values(buffer)
    end)

    start_timer

    {:noreply, %{state|buffer: []}}
  end

  defp assign_timestamp(%Stats.Series{timestamp: nil} = series) do
    %{series|timestamp: System.os_time(:nanoseconds)}
  end
  defp assign_timestamp(series) do
    series
  end

  defp start_timer do
    Process.send_after(self(), :save, notify_interval)
  end

  defp notify_interval do
    Application.get_env(:stats, :notify_interval, 1000)
  end
end
