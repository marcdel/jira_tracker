defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator

  alias JiraTracker.StoryMapper
  alias Jira.Client, as: JiraClient

  @fetch_backlog &JiraClient.backlog/1

  @decorate trace("JiraTracker.Jira.backlog", include: [:board_id])
  def backlog(team, fetch_backlog \\ @fetch_backlog) do
    team.backlog_board_id
    |> fetch_backlog.()
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

  @fetch_other_issues &JiraClient.get_issues/1

  @decorate trace("JiraTracker.Jira.other_stories", include: [:team_name])
  def other_stories(team, fetch_other_issues \\ @fetch_other_issues) do
    team.name
    |> fetch_other_issues.()
    |> case do
      {:ok, issues_json} ->
        O11y.add_span_attributes(issue_count: Enum.count(issues_json))
        {:ok, Enum.map(issues_json, &StoryMapper.issue_to_story(team, &1))}

      error ->
        error
    end
  end
end
