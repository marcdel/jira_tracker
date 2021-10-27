defmodule JiraTracker.Jira.Client do
  alias JiraTracker.Jira.AgileAPI
  alias JiraTracker.Jira.API
  alias JiraTracker.Jira.Credentials

  def backlog(board_id) do
    case AgileAPI.get("/board/#{board_id}/backlog", auth_header()) do
      {:ok, response} -> {:ok, response |> Map.get(:body) |> Map.get("issues")}
      error -> error
    end
  end

  def get_issues(project_id) do
    case API.get("/search?jql=project=#{project_id}", auth_header()) do
      {:ok, response} -> {:ok, Map.get(response, :body)}
      error -> error
    end
  end

  def auth_header() do
    auth_header(%{
      jira_username: Credentials.jira_username(),
      jira_password: Credentials.jira_password()
    })
  end

  defp auth_header(%{jira_username: username, jira_password: password}) do
    basic_auth = Base.encode64("#{username}:#{password}")
    [Authorization: "Basic #{basic_auth}"]
  end
end
