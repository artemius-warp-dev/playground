defmodule Todo.Application do
  @moduledoc """
  Applcation module
  """

  use Application

  @doc """
  Starting application
  """
  @spec start(any(), any()) ::
          {:ok, pid()}
          | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start(_, _) do
    Todo.System.start_link()
  end
end
