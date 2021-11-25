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

  describe "point_story" do
    defmodule FakeJiraClient do
      def custom_fields do
        send(self(), :custom_fields)
        {:ok, [%{"id" => "customfield_10029", "name" => "Story Points"}]}
      end

      def update(issue_key, fields) do
        send(self(), {:update, issue_key, fields})
        :ok
      end
    end

    test "gets the story point field" do
      team = team_fixture()
      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points, FakeJiraClient)

      assert_receive(:custom_fields)
    end

    test "updates the story point field on the issue to the specified value" do
      team = team_fixture()
      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points, FakeJiraClient)

      assert_receive({:update, "ISSUE-4321", %{"customfield_10029" => 5}})
    end
  end
end
