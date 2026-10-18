defmodule Prc.SetupSupervisor do
  def set_up_array_algo(data) do
    IO.inspect("Hello")
    opts = [restart: :transient]

    Task.Supervisor.start_child(__MODULE__, Prc.BinarySearch, :binary_search, [data], opts)
  end
end
