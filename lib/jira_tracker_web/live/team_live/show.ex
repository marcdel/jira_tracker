defmodule JiraTrackerWeb.TeamLive.Show do
  use JiraTrackerWeb, :live_view
  use OpenTelemetryDecorator

  alias JiraTracker.Organization
  alias JiraTracker.Jira

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.handle_params")
  def handle_params(%{"id" => id}, _, socket) do
    team = Organization.get_team!(id)

    stories =
      case Jira.backlog(team.backlog_board_id) do
        {:ok, stories} -> stories
        {:error, error} -> []
      end

    # stories = []

    {:noreply,
     socket
     |> assign(:page_title, team.name)
     |> assign(:team, team)
     |> assign(:stories, stories)}
  end
end