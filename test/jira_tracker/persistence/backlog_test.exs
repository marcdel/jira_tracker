defmodule JiraTracker.Persistence.BacklogTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Persistence.Backlog

  describe "stories" do
    test "stories/1 gets stories in the backlog for the given team" do
      team = team_fixture()
      other_team = team_fixture()

      backlog_story = story_fixture(%{team_id: team.id, in_backlog: true})
      _icebox_story = story_fixture(%{team_id: team.id, in_backlog: false})
      other_team_story = story_fixture(%{team_id: other_team.id, in_backlog: true})

      assert Backlog.stories(team) == [backlog_story]
      assert Backlog.stories(other_team) == [other_team_story]
    end
  end
end
