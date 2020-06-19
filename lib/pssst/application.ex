defmodule Pssst.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Pssst.Secret,
      PssstWeb.Telemetry,
      {Phoenix.PubSub, name: Pssst.PubSub},
      PssstWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Pssst.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    PssstWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
