defmodule JiraTrackerWeb.TeamLive.Show do
  use JiraTrackerWeb, :live_view
  use OpenTelemetryDecorator

  alias JiraTracker.Team

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.handle_params")
  def handle_params(%{"id" => id}, _, socket) do
    team = Team.get!(id)
    backlog = Team.backlog(team)
    icebox = Team.icebox(team)

    {:noreply,
     socket
     |> assign(:page_title, team.name)
     |> assign(:team, team)
     |> assign(:backlog, backlog)
     |> assign(:icebox, icebox)}
  end
end
