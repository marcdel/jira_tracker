defmodule JiraTracker.JiraTest do
  use JiraTracker.DataCase
  import JiraTracker.JiraIssuesFixtures
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Jira

  describe "fetch_issues" do
    test "fetches issues from the jira api" do
      team = team_with_settings_fixture(%{jira_settings: %{issues_jql: "project = 'JIRA'"}})
      search_fn = fn "project = 'JIRA'" -> {:ok, [issue_json(), issue_json()]} end

      {:ok, issues} = Jira.fetch_issues(team, search_fn)

      assert Enum.count(issues) == 2
    end

    test "maps issue json to stories" do
      team =
        team_with_settings_fixture(%{
          jira_settings: %{
            account_url: "example.jira.net",
            issues_jql: "project = 'JIRA'",
            story_point_field: "customfield_10029"
          }
        })

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

    test "only calls the jira custom fields endpoint once" do
      team = team_with_settings_fixture(%{jira_settings: %{story_point_field: nil}})
      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points, FakeJiraClient)
      assert_receive(:custom_fields)

      team =
        team
        |> JiraTracker.Repo.reload!()
        |> JiraTracker.Repo.preload(:jira_settings)

      assert :ok = Jira.point_story(team, issue_key, points, FakeJiraClient)
      refute_receive(:custom_fields)
    end

    test "updates the story point field on the issue to the specified value" do
      team =
        team_with_settings_fixture(%{jira_settings: %{story_point_field: "customfield_420666"}})

      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points, FakeJiraClient)

      assert_receive({:update, "ISSUE-4321", %{"customfield_420666" => 5}})
    end
  end
end
