defmodule JiraTracker.Jira.Issues do
  use OpenTelemetryDecorator
  require OpenTelemetry.Span, as: Span
  require OpenTelemetry.Tracer, as: Tracer

  alias JiraTracker.Issue

  @get_issues &ExJira.Project.get_issues/1
  @team_field "customfield_11401"
  @story_point_field "customfield_10008"

  @decorate trace("JiraTracker.Jira.Issues.fetch_by_team", include: [:project_id, :team_name])
  def fetch_by_team(project_id, team_name, get_issues \\ @get_issues) do
    case fetch(project_id, get_issues) do
      {:ok, issues_json} ->
        filtered_issues =
          issues_json
          |> Enum.map(&from_json/1)
          |> filter_by_team(team_name)

        {:ok, filtered_issues}

      error ->
        error
    end
  end

  @decorate trace("JiraTracker.Jira.Issues.fetch", include: [:project_id])
  def fetch(project_id, get_issues \\ @get_issues)

  def fetch(project_id, get_issues) when is_integer(project_id) do
    project_id
    |> Integer.to_string()
    |> fetch(get_issues)
    |> case do
      {:ok, issues_json} -> {:ok, Enum.map(issues_json, &from_json/1)}
      error -> error
    end
  end

  def fetch(project_id, get_issues) do
    get_issues.(project_id)
  end

  @decorate trace("JiraTracker.Jira.Issues.filter_by_team", include: [:team_name])
  def filter_by_team(issues, team_name) do
    filtered_issues = Enum.filter(issues, fn issue -> issue.team == team_name end)

    Span.set_attributes(Tracer.current_span_ctx(),
      issues: Enum.count(issues),
      filtered_issues: Enum.count(filtered_issues)
    )

    filtered_issues
  end

  def from_json(issue_json) do
    fields = Map.get(issue_json, "fields")

    %Issue{
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
