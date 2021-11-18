defmodule JiraTracker.StoryMapper do
  use OpenTelemetryDecorator

  alias JiraTracker.Persistence

  @team_field "customfield_11401"
  @story_point_field "customfield_10008"

  @decorate trace("JiraTracker.StoryMapper.issue_to_story", include: [:team_id, :jira_key])
  def issue_to_story(issue_json) do
    fields = Map.get(issue_json, "fields")
    team_id = team_id(fields)
    jira_key = Map.get(issue_json, "key")

    %{
      id: Map.get(issue_json, "id"),
      jira_key: jira_key,
      title: Map.get(fields, "summary"),
      description: Map.get(fields, "description"),
      team_id: team_id,
      state: state(fields),
      type: type(fields),
      labels: Map.get(fields, "labels"),
      reporter_id: reporter_id(team_id, fields),
      assignee_id: assignee_id(team_id, fields),
      points: points(fields)
    }
  end

  def subtask?(issue_json) do
    get_in(issue_json, ["fields", "issuetype", "subtask"]) == true
  end

  defp points(fields) do
    fields
    |> Map.get(@story_point_field)
    |> convert_to_integer()
  end

  defp convert_to_integer(nil), do: nil
  defp convert_to_integer(float) when is_float(float), do: trunc(float)

  defp team_id(fields) do
    case Persistence.get_team_by_name(get_in(fields, [@team_field, "value"])) do
      nil -> nil
      team -> Map.get(team, :id)
    end
  end

  defp reporter_id(team_id, fields) do
    name = get_in(fields, ["reporter", "displayName"])
    email = get_in(fields, ["reporter", "emailAddress"])

    case Persistence.create_or_get_user(%{team_id: team_id, name: name, email: email}) do
      {:ok, user} -> Map.get(user, :id)
      _ -> nil
    end
  end

  defp assignee_id(team_id, fields) do
    name = get_in(fields, ["assignee", "displayName"])
    email = get_in(fields, ["assignee", "emailAddress"])

    case Persistence.create_or_get_user(%{team_id: team_id, name: name, email: email}) do
      {:ok, user} -> Map.get(user, :id)
      _ -> nil
    end
  end

  defp state(fields) do
    case get_in(fields, ["status", "name"]) do
      "New" -> "Unstarted"
      "Dev In Progress" -> "Started"
      "Dev Code Review" -> "Finished"
      "Production Testing" -> "Delivered"
      "Done" -> "Accepted"
      _ -> "Unstarted"
    end
  end

  defp type(fields) do
    case get_in(fields, ["issuetype", "name"]) do
      "Story" -> "Feature"
      "Task" -> "Chore"
      "Bug" -> "Bug"
      _ -> "Chore"
    end
  end
end
