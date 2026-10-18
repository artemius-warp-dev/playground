defmodule Todo.Database do
  @moduledoc """
  Database server
  """

  # FUNCTIONS

  @doc """
  Children specification
  """
  @spec child_spec(any()) :: map()
  def child_spec(_) do
    db_settings = Application.fetch_env!(:todo, :database)
    [name_prefix, _] = "#{node()}" |> String.split("@")
    db_folder = "#{Keyword.fetch!(db_settings, :folder)}/#{name_prefix}/"

    File.mkdir_p(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: Keyword.fetch!(db_settings, :pool_size)
      ],
      [db_folder]
    )
  end

  @doc """
  Storing the list to remote database
  """

  @spec store(any(), any()) :: any()
  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(__MODULE__, :store_local, [key, data], :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  @doc """
  Storing the list to local database
  """
  @spec store_local(any(), any()) :: any()
  def store_local(key, data) do
    :poolboy.transaction(__MODULE__, fn worker_pid ->
      Todo.DatabaseWorker.store(worker_pid, key, data)
    end)
  end

  @doc """
  Getting the list from database
  """
  @spec get(any()) :: any()
  def get(key) do
    :poolboy.transaction(__MODULE__, fn worker_pid -> Todo.DatabaseWorker.get(worker_pid, key) end)
  end
end
