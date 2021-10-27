defmodule JiraTracker.JiraTest do
  use ExUnit.Case
  import JiraTracker.JiraIssuesFixtures

  alias JiraTracker.Issue
  alias JiraTracker.Jira

  describe "backlog" do
    test "fetches issues from the jira api for the given board" do
      fetch_fn = fn 123 -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.backlog(123, fetch_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to issue structs" do
      fetch_fn = fn 123 -> {:ok, [issue_json(%{"id" => "1", "key" => "ISSUE-4321"})]} end

      {:ok, issues} = Jira.backlog(123, fetch_fn)

      assert [%Issue{id: "1", key: "ISSUE-4321"}] = issues
    end
  end
end
