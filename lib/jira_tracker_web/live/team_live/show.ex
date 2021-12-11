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
  def handle_params(%{"id" => team_id}, _, socket) do
    team = Team.load!(team_id)

    {:noreply,
     socket
     |> assign(:page_title, team.name)
     |> assign(:team, team)}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.toggle_backlog")
  def handle_event("toggle_backlog", _value, socket) do
    {:noreply, assign(socket, :team, Team.toggle_backlog(socket.assigns.team))}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.toggle_icebox")
  def handle_event("toggle_icebox", _value, socket) do
    {:noreply, assign(socket, :team, Team.toggle_icebox(socket.assigns.team))}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.refresh")
  def handle_event("refresh", _value, socket) do
    case Team.refresh(socket.assigns.team.id) do
      {:ok, team} -> {:noreply, assign(socket, :team, team)}
      # TODO: show an error
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.point_story")
  def handle_event("point_story", %{"id" => story_id, "points" => points}, socket) do
    with {points, _} <- Integer.parse(points),
         {:ok, team} = Team.point_story(socket.assigns.team, story_id, points) do
      {:noreply, assign(socket, :team, team)}
    else
      _ -> {:noreply, socket}
    end
  end
end
