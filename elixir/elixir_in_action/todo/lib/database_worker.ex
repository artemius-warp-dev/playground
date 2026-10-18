defmodule Todo.DatabaseWorker do
  @moduledoc """
  Database worker server
  """

  use GenServer

  # FUNCTIONS

  @doc """
  Start worker server
  """
  def start_link(db_folder) do
    IO.puts("Starting database worker")
    GenServer.start_link(__MODULE__, db_folder)
  end

  @doc """
  Storing the list to database. Worker
  """
  @spec store(pid(), any(), any()) :: any()
  def store(worker_pid, key, data) do
    GenServer.call(worker_pid, {:store, key, data})
  end

  @doc """
  Getting the list from database. Worker
  """
  @spec get(pid(), any()) :: any()
  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  # CALLBACKS

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_call({:store, key, data}, _, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:reply, :ok, db_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  # HELPERS

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
