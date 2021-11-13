defmodule JiraTracker.StoryMapper do
  alias JiraTracker.Persistence

  @team_field "customfield_11401"
  @story_point_field "customfield_10008"

  def issue_to_story(issue_json) do
    fields = Map.get(issue_json, "fields")
    team_id = team_id(fields)

    %{
      id: Map.get(issue_json, "id"),
      jira_key: Map.get(issue_json, "key"),
      title: Map.get(fields, "summary"),
      description: Map.get(fields, "description"),
      team_id: team_id,
      state: state(fields),
      type: type(fields),
      labels: Map.get(fields, "labels"),
      reporter_id: reporter_id(team_id, fields),
      assignee_id: assignee_id(team_id, fields),
      points: Map.get(fields, @story_point_field)
    }
  end

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
