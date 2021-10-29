defmodule JiraTrackerWeb.TeamLive.Show do
  use JiraTrackerWeb, :live_view
  use OpenTelemetryDecorator

  alias JiraTracker.Persistence
  alias JiraTracker.Jira

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.handle_params")
  def handle_params(%{"id" => id}, _, socket) do
    team = Persistence.get_team!(id)

    stories =
      case Jira.backlog(team.backlog_board_id) do
        {:ok, stories} ->
          stories

        {:error, _error} ->
          O11y.span_attributes(error: true)
          []
      end

    #     stories = []

    {:noreply,
     socket
     |> assign(:page_title, team.name)
     |> assign(:team, team)
     |> assign(:stories, stories)}
  end
end
