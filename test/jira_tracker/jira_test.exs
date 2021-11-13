defmodule JiraTracker.JiraTest do
  use JiraTracker.DataCase
  import JiraTracker.JiraIssuesFixtures
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Persistence.Story
  alias JiraTracker.Jira

  describe "backlog" do
    setup do
      # This is the default team name in issue_json, I'm just too lazy to pass in an override.
      team_fixture(%{name: "My Team"})

      :ok
    end

    test "fetches issues from the jira api for the given board" do
      fetch_fn = fn 123 -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.backlog(123, fetch_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to issue structs" do
      fetch_fn = fn 123 -> {:ok, [issue_json(%{"id" => "1", "key" => "ISSUE-4321"})]} end

      {:ok, issues} = Jira.backlog(123, fetch_fn)

      assert [%Story{id: "1", jira_key: "ISSUE-4321"}] = issues
    end
  end
end
