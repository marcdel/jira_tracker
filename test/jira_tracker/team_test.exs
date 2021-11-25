defmodule JiraTracker.TeamTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Team
  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.Persistence

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

    defmodule FakeJira do
      def point_story(team, jira_key, points) do
        send(self(), {:point_story, team.id, jira_key, points})
        :ok
      end
    end

    test "updates the story in the database", %{team: team, story: story} do
      assert {:ok, _} = Team.point_story(team, story.id, 5, FakeJira)
      assert %{points: 5} = Persistence.get_story!(story.id)
    end

    test "updates the issue in jira", %{team: team, story: story} do
      %{id: team_id} = team
      %{id: story_id, jira_key: key} = story
      assert {:ok, _} = Team.point_story(team, story_id, 3, FakeJira)
      assert_receive({:point_story, ^team_id, ^key, 3})
    end

    test "returns team with updated story", %{team: team, story: story} do
      assert {:ok, team} = Team.point_story(team, story.id, 8, FakeJira)
      assert %{backlog: %{stories: [%{points: 8}]}} = team
    end
  end
end
