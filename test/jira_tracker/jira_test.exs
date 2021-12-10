defmodule JiraTracker.JiraTest do
  use JiraTracker.DataCase
  import JiraTracker.JiraIssuesFixtures
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Jira
  alias JiraTracker.JiraClientMock

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
    test "only calls the jira custom fields endpoint once" do
      JiraClientMock
      |> expect(:custom_fields, 1, fn ->
        {:ok, [%{"id" => "customfield_10029", "name" => "Story Points"}]}
      end)
      |> expect(:update, 2, fn _key, _fields -> :ok end)

      team = team_with_settings_fixture(%{jira_settings: %{story_point_field: nil}})
      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points)

      team =
        team
        |> JiraTracker.Repo.reload!()
        |> JiraTracker.Repo.preload(:jira_settings)

      assert :ok = Jira.point_story(team, issue_key, points)
    end

    test "updates the jira_settings table with the point field id" do
      JiraClientMock
      |> expect(:custom_fields, fn ->
        {:ok, [%{"id" => "customfield_12345", "name" => "Story Points"}]}
      end)
      |> expect(:update, fn _key, _fields -> :ok end)

      team = team_with_settings_fixture(%{jira_settings: %{story_point_field: nil}})

      assert :ok = Jira.point_story(team, "ISSUE-4321", 3)

      team =
        team
        |> JiraTracker.Repo.reload!()
        |> JiraTracker.Repo.preload(:jira_settings)

      assert team.jira_settings.story_point_field == "customfield_12345"
    end

    test "updates the story point field on the issue to the specified value" do
      expect(JiraClientMock, :update, fn "ISSUE-4321", %{"customfield_420666" => 5} -> :ok end)

      team =
        team_with_settings_fixture(%{jira_settings: %{story_point_field: "customfield_420666"}})

      issue_key = "ISSUE-4321"
      points = 5

      assert :ok = Jira.point_story(team, issue_key, points)
    end
  end
end
