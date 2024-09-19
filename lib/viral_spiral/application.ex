defmodule ViralSpiral.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ViralSpiralWeb.Telemetry,
      ViralSpiral.Repo,
      {DNSCluster, query: Application.get_env(:viral_spiral, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ViralSpiral.PubSub},
      ViralSpiral.Room,
      # Start the Finch HTTP client for sending emails
      {Finch, name: ViralSpiral.Finch},
      # Start a worker by calling: ViralSpiral.Worker.start_link(arg)
      # {ViralSpiral.Worker, arg},
      # Start to serve requests, typically the last entry
      ViralSpiralWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ViralSpiral.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ViralSpiralWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
