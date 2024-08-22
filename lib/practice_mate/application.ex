defmodule PracticeMate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias PracticeMate.TokenStore

  @impl true
  def start(_type, _args) do
    children = [
      PracticeMateWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:practice_mate, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PracticeMate.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PracticeMate.Finch},
      # Start a worker by calling: PracticeMate.Worker.start_link(arg)
      # {PracticeMate.Worker, arg},
      # Start to serve requests, typically the last entry
      {TokenStore.Registry, name: TokenStore.Registry},
      {DynamicSupervisor, name: TokenStore.BucketSupervisor, strategy: :one_for_one},
      PracticeMateWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PracticeMate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PracticeMateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
