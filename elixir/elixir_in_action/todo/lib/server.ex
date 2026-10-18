defmodule Todo.Server do
  @moduledoc """
  Server to operate with to-do list
  """
  use GenServer, restart: :temporary

  @expiry_idle_timeout Application.fetch_env!(:todo, :todo_item_expiry)

  # FUNCTIONS

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end


  @doc """
  Starting to-do server 
  """
  @spec start_link(any()) :: {:ok, pid()} | :error
  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: global_name(name))
  end

  @doc """
  Adding entry to to-do server. Asynchronyos.
  """
  @spec add_entry(pid(), any()) :: any()
  def add_entry(todo_server, new_entry) do
    GenServer.call(todo_server, {:add_entry, new_entry})
  end

  @doc """
  Getting entry from to-do server. Syncronyos
  """
  @spec entries(pid(), any()) :: any()
  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # CALLBACKS

  @impl GenServer
  def init(name) do
     IO.puts("Starting to-do server for #{name}.")
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:add_entry, new_entry}, _, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:reply, :ok, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {name, todo_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {:name, todo_list}}
  end

  # HELPERS
  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end
  
end
