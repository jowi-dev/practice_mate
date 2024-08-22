defmodule PracticeMate.TokenStore.Supervisor do
  use Supervisor

  alias PracticeMate.TokenStore.{Registry, Bucket}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      Registry,
      name: Registry
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
