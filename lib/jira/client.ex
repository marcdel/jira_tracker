defmodule Jira.Client do
  use OpenTelemetryDecorator

  alias Jira.AgileAPI
  alias Jira.API
  alias Jira.Credentials

  @team_name_field "Dev Team"

  @decorate trace("Jira.Client.backlog", include: [:board_id])
  def backlog(board_id) do
    case AgileAPI.get("/board/#{board_id}/backlog", auth_header()) do
      {:ok, response} -> {:ok, response |> Map.get(:body) |> Map.get("issues")}
      error -> error
    end
  end

  @decorate trace("Jira.Client.get_issues", include: [:team_name])
  def get_issues(team_name) do
    url = "/search?jql=\"#{URI.encode(@team_name_field)}\"=\"#{URI.encode(team_name)}\""

    case API.get(url, auth_header()) do
      {:ok, response} -> {:ok, response |> Map.get(:body) |> Map.get("issues")}
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
