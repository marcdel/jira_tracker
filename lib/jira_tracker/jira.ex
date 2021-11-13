defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator

  alias JiraTracker.StoryMapper
  alias Jira.Client, as: JiraClient

  @fetch_backlog &JiraClient.backlog/1

  @decorate trace("JiraTracker.Jira.backlog", include: [:board_id])
  def backlog(board_id, fetch_backlog \\ @fetch_backlog) do
    board_id
    |> fetch_backlog.()
    |> case do
      {:ok, issues_json} ->
        O11y.span_attributes(issue_count: Enum.count(issues_json))
        {:ok, Enum.map(issues_json, &StoryMapper.issue_to_story/1)}

      error ->
        error
    end
  end
end
