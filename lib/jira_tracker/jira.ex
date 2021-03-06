defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator
  require Logger

  alias Jira.Client, as: JiraClient
  alias JiraTracker.Persistence
  alias JiraTracker.Story
  alias JiraTracker.StoryMapper

  @type story_id :: String.t()
  @type story_points :: Integer.t()

  @callback fetch_issues(Persistence.Team.t()) :: {:ok, list(Story)} | {:error, any()}
  @callback point_story(Persistence.Team.t(), story_id, story_points) :: :ok | :error

  @search &JiraClient.search/1

  @decorate trace("JiraTracker.Jira.fetch_issues")
  def fetch_issues(team, search \\ @search) do
    O11y.add_span_attributes(team_id: team.id, jql: team.jira_settings.issues_jql)

    team.jira_settings.issues_jql
    |> search.()
    |> case do
      {:ok, issues_json} ->
        O11y.add_span_attributes(issue_count: Enum.count(issues_json))

        stories =
          issues_json
          |> Enum.reject(&StoryMapper.subtask?/1)
          |> Enum.map(&StoryMapper.issue_to_story(team, &1))

        O11y.add_span_attributes(stories_count: Enum.count(stories))

        {:ok, stories}

      error ->
        Logger.error(inspect(error))
        error
    end
  end

  @decorate trace("JiraTracker.Jira.point_story", include: [[:team, :id], :issue_key, :points])
  def point_story(team, issue_key, points) do
    field_id = story_point_field_id(team)
    jira_client().update(issue_key, Map.put(%{}, field_id, points))
  end

  defp story_point_field_id(team) do
    case team.jira_settings.story_point_field do
      nil -> fetch_story_point_field_id(team)
      field_id -> field_id
    end
  end

  @decorate trace("JiraTracker.Jira.fetch_story_point_field_id")
  defp fetch_story_point_field_id(team) do
    with {:ok, fields} <- jira_client().custom_fields(),
         {:ok, field_id} <- find_story_point_field_in_map(fields),
         {:ok, _settings} <-
           JiraTracker.Persistence.update_jira_settings(team.jira_settings, %{
             story_point_field: field_id
           }) do
      field_id
    else
      _ -> nil
    end
  end

  defp find_story_point_field_in_map(fields) do
    field_id =
      fields
      |> Enum.find(%{}, fn field -> Map.get(field, "name") == "Story Points" end)
      |> Map.get("id")
      |> O11y.pipe_span_attribute(:story_point_field_id)

    case field_id do
      nil -> {:error, "Could not find Story Points field"}
      field_id -> {:ok, field_id}
    end
  end

  defp jira_client do
    Application.get_env(:jira_tracker, :jira_client, Jira.Client)
  end
end
