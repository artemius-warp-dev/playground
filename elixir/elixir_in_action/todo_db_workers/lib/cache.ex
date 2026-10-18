defmodule Todo.Cache do
  @moduledoc """
  Module for dynamic supervise to-do cache servers
  """

  # FUNCTIONS

  @doc """
  Starting to-do cache server
  """
  @spec start_link() :: {:ok, pid()} | :error
  def start_link() do
    IO.puts("Starting to-do cache.")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @doc """
  Child specification
  """
  @spec child_spec(any()) :: map()
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @doc """
  Client function for server process
  """
  @spec server_process(any()) :: pid()
  def server_process(todo_list_name) do
    case start_child(todo_list_name) |> IO.inspect() do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # HELPERS
  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(__MODULE__, {Todo.Server, todo_list_name})
  end
end
