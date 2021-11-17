defmodule JiraTracker.StoryMapperTest do
  use JiraTracker.DataCase
  import JiraTracker.PersistenceFixtures

  alias JiraTracker.StoryMapper
  alias JiraTracker.Persistence
  alias JiraTracker.Persistence.Story

  test "issue_to_story/1 maps the issue fields to story fields" do
    issue_json = %{
      "fields" => %{
        "summary" => "Story title goes here!",
        "customfield_10003" => [
          %{
            "name" => "Groomed"
          }
        ],
        "status" => %{
          "name" => "New"
        },
        "issuetype" => %{
          "name" => "Story"
        },
        "customfield_11401" => %{
          "value" => "My Team"
        },
        "customfield_10008" => 3.0,
        "assignee" => %{
          "displayName" => "Jane Doe",
          "emailAddress" => "jane.doe@email.com"
        },
        "reporter" => %{
          "displayName" => "John Doe",
          "emailAddress" => "john.doe@email.com"
        },
        "description" => "The *description* of the story goes _here_",
        "labels" => ["good-stuff"]
      },
      "id" => "1",
      "key" => "ISSUE-4321"
    }

    team = team_fixture(%{name: "My Team"})

    story = StoryMapper.issue_to_story(issue_json)
    changeset = Persistence.change_story(%Story{}, story)

    assert changeset.valid?

    assert story.id == "1"
    assert story.jira_key == "ISSUE-4321"
    assert story.title == "Story title goes here!"
    assert story.description == "The *description* of the story goes _here_"
    assert story.team_id == team.id
    assert story.state == "Unstarted"
    assert story.type == "Feature"
    assert story.labels == ["good-stuff"]
    assert story.points == 3
    assert story.assignee_id != nil
    assert story.reporter_id != nil
  end

  test "handles nil story points" do
    issue_json = %{
      "fields" => %{
        "summary" => "Story title goes here!",
        "customfield_10003" => [
          %{
            "name" => "Groomed"
          }
        ],
        "status" => %{
          "name" => "New"
        },
        "issuetype" => %{
          "name" => "Story"
        },
        "customfield_11401" => %{
          "value" => "My Team"
        },
        "customfield_10008" => nil,
        "assignee" => %{
          "displayName" => "Jane Doe",
          "emailAddress" => "jane.doe@email.com"
        },
        "reporter" => %{
          "displayName" => "John Doe",
          "emailAddress" => "john.doe@email.com"
        },
        "description" => "The *description* of the story goes _here_",
        "labels" => ["good-stuff"]
      },
      "id" => "1",
      "key" => "ISSUE-4321"
    }

    team_fixture(%{name: "My Team"})

    story = StoryMapper.issue_to_story(issue_json)
    changeset = Persistence.change_story(%Story{}, story)

    assert story.points == nil
    assert changeset.valid?
  end
end
