defmodule JiraTracker.Jira.Issues do
  alias JiraTracker.Issue

  @get_issues &ExJira.Project.get_issues/1
  @team_field "customfield_11401"

  def fetch_by_team(project_id, team_name, get_issues \\ @get_issues) do
    case fetch(project_id, get_issues) do
      {:ok, issues} -> {:ok, filter_by_team(issues, team_name)}
      error -> error
    end
  end

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

  def filter_by_team(issues, team_name) do
    Enum.filter(issues, fn issue -> issue.team == team_name end)
  end

  defp from_json(issue_json) do
    fields = Map.get(issue_json, "fields")

    %Issue{
      id: Map.get(issue_json, "id"),
      key: Map.get(issue_json, "key"),
      title: Map.get(fields, "summary"),
      description: Map.get(fields, "description"),
      team: get_in(fields, [@team_field, "value"]),
      state: get_in(fields, ["status", "name"]),
      type: get_in(fields, ["issuetype", "name"]),
      labels: Map.get(fields, "labels")
    }
  end
end
