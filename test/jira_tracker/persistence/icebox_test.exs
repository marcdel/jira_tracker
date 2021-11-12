defmodule JiraTracker.Persistence.IceboxTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.Persistence.Icebox

  describe "stories" do
    test "stories/1 gets stories in the backlog for the given team" do
      team = team_fixture()
      other_team = team_fixture()

      _backlog_story = story_fixture(%{team_id: team.id, in_backlog: true})
      icebox_story = story_fixture(%{team_id: team.id, in_backlog: false})
      other_team_story = story_fixture(%{team_id: other_team.id, in_backlog: false})

      assert Icebox.stories(team) == [icebox_story]
      assert Icebox.stories(other_team) == [other_team_story]
    end
  end
end
