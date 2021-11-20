defmodule JiraTracker.Team do
  use OpenTelemetryDecorator

  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.Persistence

  defstruct [:id, :name, :jira_issues_jql, :backlog, :icebox]

  @decorate trace("JiraTracker.Team.load!", include: [:team_id])
  def load!(team_id) do
    team = Persistence.get_team!(team_id)

    %__MODULE__{
      id: team.id,
      name: team.name,
      jira_issues_jql: team.jira_issues_jql,
      backlog: Backlog.get(team),
      icebox: Icebox.get(team)
    }
  end

  @decorate trace("JiraTracker.Team.toggle_backlog")
  def toggle_backlog(team), do: put_in(team.backlog.open, !team.backlog.open)

  @decorate trace("JiraTracker.Team.toggle_icebox")
  def toggle_icebox(team), do: put_in(team.icebox.open, !team.icebox.open)

  @decorate trace("JiraTracker.Team.point_story", include: [:story_id, :points])
  def point_story(story_id, points) do
    # TODO: handle errors
    story = Persistence.get_story!(story_id)
    Persistence.update_story(story, %{points: points})
  end

  def refresh(team) do
    %{team | backlog: Backlog.get(team), icebox: Icebox.refresh(team)}
  end

  def icebox(team) do
    case Icebox.get(team) do
      %{stories: []} -> Icebox.refresh(team)
      icebox -> icebox
    end
  end
end
