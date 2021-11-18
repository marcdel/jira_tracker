defmodule JiraTracker.Team do
  use OpenTelemetryDecorator

  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.Persistence

  defstruct [:id, :name, :backlog, :icebox]

  @decorate trace("JiraTracker.Team.load!", include: [:team_id])
  def load!(team_id) do
    team = Persistence.get_team!(team_id)

    %__MODULE__{
      id: team.id,
      name: team.name,
      backlog: backlog(team),
      icebox: icebox(team)
    }
  end

  @decorate trace("JiraTracker.Team.point_story", include: [:story_id, :points])
  def point_story(story_id, points) do
    # TODO: handle errors
    story = Persistence.get_story!(story_id)
    Persistence.update_story(story, %{points: points})
  end

  def get!(id), do: Persistence.get_team!(id)

  def refresh(team) do
    %{backlog: Backlog.refresh(team), icebox: Icebox.refresh(team)}
  end

  def backlog(team) do
    case Backlog.get(team) do
      %{stories: []} -> Backlog.refresh(team)
      backlog -> backlog
    end
  end

  def icebox(team) do
    case Icebox.get(team) do
      %{stories: []} -> Icebox.refresh(team)
      icebox -> icebox
    end
  end
end
