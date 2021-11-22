defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator

  alias JiraTracker.StoryMapper
  alias Jira.Client, as: JiraClient

  @search &JiraClient.search/1

  @decorate trace("JiraTracker.Jira.search", include: [:jql])
  def fetch_issues(team, search \\ @search) do
    team.jira_issues_jql
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
end
