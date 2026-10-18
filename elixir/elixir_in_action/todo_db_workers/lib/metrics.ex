defmodule Todo.Metrics do
  @moduledoc """
  Functions for collect metrics
  """

  use Task

  # FUNCTIONS

  @doc """
  Start metrics loop
  """
  @spec start_link(any) :: any()
  def start_link(_) do
    Task.start_link(&loop/0)
  end

  # HELPERS

  defp loop() do
    Process.sleep(:timer.seconds(10))
    IO.inspect(collect_metrics())
    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
