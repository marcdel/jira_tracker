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
     |> assign(:team, team)
     |> assign(:backlog, team.backlog)
     |> assign(:icebox, team.icebox)}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.toggle_backlog")
  def handle_event("toggle_backlog", _value, socket) do
    backlog = socket.assigns.backlog
    new_backlog = %{backlog | open: !backlog.open}
    {:noreply, assign(socket, :backlog, new_backlog)}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.toggle_icebox")
  def handle_event("toggle_icebox", _value, socket) do
    icebox = socket.assigns.icebox
    new_icebox = %{icebox | open: !icebox.open}
    {:noreply, assign(socket, :icebox, new_icebox)}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.refresh")
  def handle_event("refresh", _value, socket) do
    %{backlog: backlog, icebox: icebox} = Team.refresh(socket.assigns.team)

    socket =
      socket
      |> assign(:backlog, backlog)
      |> assign(:icebox, icebox)

    {:noreply, socket}
  end

  @impl true
  @decorate trace("JiraTrackerWeb.TeamLive.Show.point_story")
  def handle_event("point_story", value, socket) do
    IO.inspect(value, label: "point_story value")

    {:noreply, socket}
  end
end
