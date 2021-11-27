defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator

  alias JiraTracker.StoryMapper
  alias Jira.Client, as: JiraClient

  @search &JiraClient.search/1

  @decorate trace("JiraTracker.Jira.search", include: [:jql])
  def fetch_issues(team, search \\ @search) do
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
        error
    end
  end

  @decorate trace("JiraTracker.Jira.point_story", include: [[:team, :id], :issue_key, :points])
  def point_story(_team, issue_key, points, jira_client \\ JiraClient) do
    field_id = story_point_field_id(jira_client)
    jira_client.update(issue_key, Map.put(%{}, field_id, points))
  end

  @decorate trace("JiraTracker.Jira.story_point_field_id")
  defp story_point_field_id(jira_client \\ JiraClient) do
    case jira_client.custom_fields() do
      {:ok, fields} ->
        fields
        |> Enum.find(%{}, fn field -> Map.get(field, "name") == "Story Points" end)
        |> Map.get("id")
        |> O11y.pipe_span_attribute(:story_point_field_id)

      {:error, _error} ->
        nil
    end
  end
end
