defmodule Prc.Application do
  use Application

  def start(_type, _args) do
    IO.inspect("Application start")

    children = [
      {Task.Supervisor, name: Prc.SetupSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Prc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
