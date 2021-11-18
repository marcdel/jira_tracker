defmodule JiraTracker.TeamTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Team
  alias JiraTracker.Backlog
  alias JiraTracker.Icebox

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
      assert team.backlog.open == true
    end

    test "loads the icebox", %{team_id: team_id, icebox_story: icebox_story} do
      team = Team.load!(team_id)
      assert %Icebox{stories: [^icebox_story]} = team.icebox
      assert team.icebox.open == false
    end
  end

  describe "point_story/2" do
    setup do
      team = team_fixture()
      backlog_story = story_fixture(%{team_id: team.id, in_backlog: true})
      icebox_story = story_fixture(%{team_id: team.id, in_backlog: false})

      {:ok, team_id: team.id, backlog_story: backlog_story, icebox_story: icebox_story}
    end

    test "updates the story in the database", %{
      team_id: team_id,
      backlog_story: backlog_story,
      icebox_story: icebox_story
    } do
      {:ok, _} = Team.point_story(backlog_story.id, 3)
      {:ok, _} = Team.point_story(icebox_story.id, 1)

      team = Team.load!(team_id)
      assert %Backlog{stories: [%{points: 3}]} = team.backlog
      assert %Icebox{stories: [%{points: 1}]} = team.icebox
    end

    test "updates the issue in jira" do
    end
  end
end
