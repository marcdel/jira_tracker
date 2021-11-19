defmodule JiraTracker.JiraTest do
  use JiraTracker.DataCase
  import JiraTracker.JiraIssuesFixtures
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Jira

  describe "backlog" do
    test "fetches issues from the jira api for the given board" do
      team = team_fixture(%{name: "My Team", backlog_board_id: 123})
      fetch_fn = fn 123 -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.backlog(team, fetch_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to issue structs" do
      team = team_fixture(%{name: "My Team", backlog_board_id: 123})
      fetch_fn = fn 123 -> {:ok, [issue_json(%{"id" => "1", "key" => "ISSUE-4321"})]} end

      {:ok, issues} = Jira.backlog(team, fetch_fn)

      assert [%{id: "1", jira_key: "ISSUE-4321"}] = issues
    end
  end

  describe "other_stories" do
    test "fetches issues from the jira api for the given board" do
      team = team_fixture(%{name: "My Team"})
      fetch_fn = fn "My Team" -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.other_stories(team, fetch_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to issue structs" do
      team = team_fixture(%{name: "My Team"})
      fetch_fn = fn "My Team" -> {:ok, [issue_json(%{"id" => "1", "key" => "ISSUE-4321"})]} end

      {:ok, issues} = Jira.other_stories(team, fetch_fn)

      assert [%{id: "1", jira_key: "ISSUE-4321"}] = issues
    end
  end
end
