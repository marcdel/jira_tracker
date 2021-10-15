defmodule JiraTracker.Jira do
  @get_issues &ExJira.Project.get_issues/1

  def fetch_issues(project_id, get_issues \\ @get_issues)

  def fetch_issues(project_id, get_issues) when is_integer(project_id) do
    project_id
    |> Integer.to_string()
    |> fetch_issues(get_issues)
  end

  def fetch_issues(project_id, get_issues) do
    get_issues.(project_id)
  end
end
