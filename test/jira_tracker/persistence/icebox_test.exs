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

  describe "add_new_stories" do
    test "adds new stories, does not update existing stories, does not add invalid stories" do
      team = team_fixture()
      %{id: team_id} = team

      story_fixture(%{
        team_id: team.id,
        jira_key: "ISSUE-1",
        title: "Existing Story",
        in_backlog: false
      })

      existing_story = %{
        jira_key: "ISSUE-1",
        title: "Updated Existing Story",
        state: "unstarted",
        type: "feature"
      }

      new_story = %{jira_key: "ISSUE-2", title: "New Story", state: "unstarted", type: "feature"}

      invalid_story = %{jira_key: "ISSUE-3", title: "Invalid Story"}

      assert [{:ok, _}, {:ok, _}, {:error, _}] =
               Icebox.add_new_stories(team, [new_story, existing_story, invalid_story])

      assert [
               %{
                 team_id: ^team_id,
                 jira_key: "ISSUE-1",
                 title: "Existing Story",
                 in_backlog: false
               },
               %{
                 team_id: ^team_id,
                 jira_key: "ISSUE-2",
                 title: "New Story",
                 in_backlog: false
               }
             ] =
               Icebox.stories(team)
               |> Enum.sort_by(&Map.get(&1, :jira_key))
    end
  end
end
