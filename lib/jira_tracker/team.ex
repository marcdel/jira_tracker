defmodule JiraTracker.Team do
  use OpenTelemetryDecorator

  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.Jira
  alias JiraTracker.Persistence

  defstruct [
    :id,
    :name,
    :backlog,
    :icebox,
    :backlog_open,
    :icebox_open,
    :jira_issues_jql,
    :account_url,
    :story_point_field
  ]

  @decorate trace("JiraTracker.Team.load!", include: [:team_id])
  def load!(team_id) do
    team = Persistence.get_team!(team_id, :jira_settings)
    jira_settings = team.jira_settings || %Persistence.JiraSettings{}

    %__MODULE__{
      id: team.id,
      name: team.name,
      backlog_open: team.backlog_open,
      icebox_open: team.icebox_open,
      account_url: jira_settings.account_url,
      jira_issues_jql: jira_settings.issues_jql,
      story_point_field: jira_settings.story_point_field,
      backlog: Backlog.get(team),
      icebox: Icebox.get(team)
    }
  end

  @decorate trace("JiraTracker.Team.toggle_backlog")
  def toggle_backlog(team) do
    team.id
    |> Persistence.get_team!()
    |> Persistence.update_team(%{backlog_open: !team.backlog_open})

    %{team | backlog_open: !team.backlog_open}
  end

  @decorate trace("JiraTracker.Team.toggle_icebox")
  def toggle_icebox(team) do
    team.id
    |> Persistence.get_team!()
    |> Persistence.update_team(%{icebox_open: !team.icebox_open})

    %{team | icebox_open: !team.icebox_open}
  end

  @decorate trace("JiraTracker.Team.point_story", include: [:story_id, :points])
  def point_story(team, story_id, points, jira \\ Jira) do
    with story = Persistence.get_story!(story_id),
         :ok <- jira.point_story(team, story.jira_key, points),
         {:ok, _} <- Persistence.update_story(story, %{points: points}) do
      {:ok, load!(team.id)}
    else
      :error -> {:error, :error_updating_jira}
      error -> error
    end
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
