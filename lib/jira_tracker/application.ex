defmodule JiraTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup()
    OpentelemetryEcto.setup([:jira_tracker, :repo])

    children = [
      # Start the Ecto repository
      JiraTracker.Repo,
      # Start the Telemetry supervisor
      JiraTrackerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: JiraTracker.PubSub},
      # Start the Endpoint (http/https)
      JiraTrackerWeb.Endpoint
      # Start a worker by calling: JiraTracker.Worker.start_link(arg)
      # {JiraTracker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JiraTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JiraTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
