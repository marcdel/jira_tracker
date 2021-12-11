defmodule JiraTracker.TeamTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures
  import JiraTracker.JiraIssuesFixtures

  alias JiraTracker.Team
  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.JiraMock
  alias JiraTracker.Persistence
  alias JiraTracker.StoryMapper

  describe "create" do
    test "creates a team record" do
      {:ok, %Team{id: created_team_id}} =
        Team.create(%{
          name: "Team 1",
          jira_issues_jql: "project = 'TEST'",
          account_url: "example.jira.com"
        })

      %{id: found_team_id} = Persistence.get_team_by_name("Team 1")
      assert(found_team_id == created_team_id)
    end

    test "creates a jira settings record" do
    end
  end

  describe "load/1" do
    setup do
      team = team_fixture()
      backlog_story = story_fixture(%{team_id: team.id, in_backlog: true})
      icebox_story = story_fixture(%{team_id: team.id, in_backlog: false})

      {:ok, team_id: team.id, backlog_story: backlog_story, icebox_story: icebox_story}
    end

    test "loads the backlog", %{team_id: team_id, backlog_story: backlog_story} do
      team = Team.load!(team_id)
      assert %Backlog{stories: [^backlog_story]} = team.backlog
      assert team.backlog_open == true
    end

    test "loads the icebox", %{team_id: team_id, icebox_story: icebox_story} do
      team = Team.load!(team_id)
      assert %Icebox{stories: [^icebox_story]} = team.icebox
      assert team.icebox_open == true
    end

    test "loads the jira settings" do
      team_entity =
        team_with_settings_fixture(%{
          jira_settings: %{
            account_url: "example.jira.net",
            issues_jql: "project = 'JIRA'",
            story_point_field: "customfield_10029"
          }
        })

      team = Team.load!(team_entity.id)
      assert team.account_url == "example.jira.net"
      assert team.jira_issues_jql == "project = 'JIRA'"
      assert team.story_point_field == "customfield_10029"
    end
  end

  describe "toggle_backlog" do
    test "updates the value of backlog_open in the database" do
      team_record = team_fixture(%{backlog_open: true})
      team = Team.load!(team_record.id)
      assert %{backlog_open: false} = Team.toggle_backlog(team)
    end
  end

  describe "toggle_icebox" do
    test "updates the value of icebox_open in the database" do
      team_record = team_fixture(%{icebox_open: true})
      team = Team.load!(team_record.id)
      assert %{icebox_open: false} = Team.toggle_icebox(team)
    end
  end

  describe "point_story/2" do
    setup do
      team = team_fixture()
      story = story_fixture(%{team_id: team.id, jira_key: "ISSUE-1", in_backlog: true})

      {:ok, team: team, story: story}
    end

    test "updates the story in the database", %{team: team, story: story} do
      expect(JiraMock, :point_story, fn _team, _jira_key, _points -> :ok end)
      assert {:ok, _} = Team.point_story(team, story.id, 5)
      assert %{points: 5} = Persistence.get_story!(story.id)
    end

    test "updates the issue in jira", %{team: %{id: team_id} = team, story: story} do
      %{id: story_id, jira_key: key} = story
      expect(JiraMock, :point_story, fn %{id: ^team_id}, ^key, 3 -> :ok end)
      assert {:ok, _} = Team.point_story(team, story_id, 3)
    end

    test "returns team with updated story", %{team: %{id: team_id} = team, story: story} do
      %{id: story_id, jira_key: key} = story
      expect(JiraMock, :point_story, fn %{id: ^team_id}, ^key, 8 -> :ok end)

      assert {:ok, updated_team} = Team.point_story(team, story_id, 8)

      assert %{backlog: %{stories: [%{points: 8}]}} = updated_team
    end
  end

  describe "refresh/1" do
    test "refreshes the icebox from jira" do
      %{id: team_id} = team_with_settings_fixture()
      team = Team.load!(team_id)

      stories =
        [issue_json_fixture(%{"key" => "ISSUE-1"}), issue_json_fixture(%{"key" => "ISSUE-2"})]
        |> Enum.map(&StoryMapper.issue_to_story(team, &1))

      JiraTracker.JiraMock
      |> expect(:fetch_issues, fn _team -> {:ok, stories} end)

      assert {:ok, updated_team} = Team.refresh(team)
      assert %{icebox: %{stories: icebox_stories}} = updated_team
      assert [%{jira_key: "ISSUE-1"}, %{jira_key: "ISSUE-2"}] = icebox_stories

      assert [%{jira_key: "ISSUE-1"}, %{jira_key: "ISSUE-2"}] =
               team_id
               |> Persistence.list_stories(in_backlog: false)
               |> Enum.sort_by(&Map.get(&1, :jira_key))
    end
  end
end
