defmodule JiraTracker.Jira do
  use OpenTelemetryDecorator

  alias JiraTracker.Story
  alias Jira.Client, as: JiraClient

  @fetch_backlog &JiraClient.backlog/1

  @team_field "customfield_11401"
  @story_point_field "customfield_10008"

  @decorate trace("JiraTracker.Jira.backlog", include: [:board_id])
  def backlog(board_id, fetch_backlog \\ @fetch_backlog) do
    board_id
    |> fetch_backlog.()
    |> case do
      {:ok, issues_json} ->
        O11y.span_attributes(issue_count: Enum.count(issues_json))
        {:ok, Enum.map(issues_json, &to_struct/1)}

      error ->
        error
    end
  end

  defp to_struct(issue_json) do
    fields = Map.get(issue_json, "fields")

    %Story{
      id: Map.get(issue_json, "id"),
      key: Map.get(issue_json, "key"),
      title: Map.get(fields, "summary"),
      description: Map.get(fields, "description"),
      team: get_in(fields, [@team_field, "value"]),
      state: get_in(fields, ["status", "name"]),
      type: get_in(fields, ["issuetype", "name"]),
      labels: Map.get(fields, "labels"),
      reporter: get_in(fields, ["reporter", "displayName"]),
      assignee: get_in(fields, ["assignee", "displayName"]),
      story_points: Map.get(fields, @story_point_field)
    }
  end
end
