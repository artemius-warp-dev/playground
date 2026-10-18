defmodule Todo.Database do
  @moduledoc """
  Database server
  """
  @pool_size 3
  @db_folder "./persist"

  # FUNCTIONS

  @doc """
  Start server
  """
  @spec start_link() :: {:ok, pid()} | :error
  def start_link() do
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Children specification
  """
  @spec child_spec(any()):: map()
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @doc """
  Storing the list to database
  """
  @spec store(any(), any()) :: any()
  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  @doc """
  Getting the list from database
  """
  @spec get(any()) :: any()
  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  # HELPERS

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

end
