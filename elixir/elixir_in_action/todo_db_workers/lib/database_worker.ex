defmodule Todo.DatabaseWorker do
  @moduledoc """
  Database worker server
  """

  use GenServer

  # FUNCTIONS

  @doc """
  Start worker server
  """
  def start_link({db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  @doc """
  Storing the list to database. Worker
  """
  @spec store(pid(), any(), any()) :: any()
  def store(worker_pid, key, data) do
    GenServer.cast(via_tuple(worker_pid), {:store, key, data})
  end

  @doc """
  Getting the list from database. Worker
  """
  @spec get(pid(), any()) :: any()
  def get(worker_pid, key) do
    GenServer.call(via_tuple(worker_pid), {:get, key})
  end

  # CALLBACKS

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
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

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
