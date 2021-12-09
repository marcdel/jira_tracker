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

  @decorate trace("JiraTracker.Team.create")
  def create(attrs) do
    with {:ok, team} <- Persistence.create_team(%{name: attrs.name}),
         {:ok, _jira_settings} <- Persistence.create_jira_settings(%{
           team_id: team.id,
           issues_jql: attrs.jira_issues_jql,
           account_url: attrs.account_url
         }) do
      {:ok, load!(team.id)}
    else
      error -> error
    end
  end

  @decorate trace("JiraTracker.Team.load!", include: [:team_id])
  def load!(team_id) do
    team_id
    |> Persistence.get_team!(:jira_settings)
    |> team_entity_to_team()
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

  alias JiraTracker.Persistence.Icebox, as: DbIcebox

  def refresh(%{id: team_id} = team) do
    with team_entity <- Persistence.get_team!(team_id, :jira_settings),
         {:ok, unsaved_stories} <- jira().fetch_issues(team_entity),
         _results <- DbIcebox.add_new_stories(team_entity, unsaved_stories),
         icebox_stories <- DbIcebox.stories(team) do
      {:ok, put_in(team.icebox.stories, icebox_stories)}
    else
      _error -> {:error, team}
    end
  end

  defp team_entity_to_team(team_entity) do
    jira_settings = team_entity.jira_settings || %Persistence.JiraSettings{}

    %__MODULE__{
      id: team_entity.id,
      name: team_entity.name,
      backlog_open: team_entity.backlog_open,
      icebox_open: team_entity.icebox_open,
      account_url: jira_settings.account_url,
      jira_issues_jql: jira_settings.issues_jql,
      story_point_field: jira_settings.story_point_field,
      backlog: Backlog.get(team_entity),
      icebox: Icebox.get(team_entity)
    }
  end

  defp jira do
    Application.get_env(:jira_tracker, :jira, Jira)
  end
end
