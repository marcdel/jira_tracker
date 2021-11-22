defmodule JiraTracker.JiraTest do
  use JiraTracker.DataCase
  import JiraTracker.JiraIssuesFixtures
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Jira

  describe "fetch_issues" do
    test "fetches issues from the jira api" do
      team = team_fixture(%{jira_issues_jql: "project = 'JIRA'"})
      search_fn = fn "project = 'JIRA'" -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.fetch_issues(team, search_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to stories" do
      team = team_fixture(%{jira_issues_jql: "project = 'JIRA'"})

      search_fn = fn "project = 'JIRA'" ->
        {:ok, [issue_json(%{"id" => "1", "key" => "ISSUE-4321"})]}
      end

      {:ok, issues} = Jira.fetch_issues(team, search_fn)

      assert [%{id: "1", jira_key: "ISSUE-4321"}] = issues
    end
  end
end
