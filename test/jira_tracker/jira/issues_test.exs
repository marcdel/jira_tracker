defmodule JiraTracker.Jira.IssuesTest do
  use ExUnit.Case

  alias JiraTracker.Jira.Issues
  alias JiraTracker.Issue

  describe "fetch" do
    test "fetches issues for the given project" do
      get_issues = fn
        "1234" -> {:ok, []}
        id -> raise "expected to be called with 1234 as a string, but was called with #{id}"
      end

      {:ok, []} = Issues.fetch(1234, get_issues)
    end

    test "maps results to issue structs" do
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
            "displayName" => "Jane Doe"
          },
          "reporter" => %{
            "displayName" => "Jane Doe"
          },
          "description" => "The *description* of the story goes _here_",
          "labels" => ["good-stuff"]
        },
        "id" => "1",
        "key" => "ISSUE-4321"
      }

      get_issues = fn _ -> {:ok, [issue_json]} end

      {:ok, [issue]} = Issues.fetch(1234, get_issues)

      assert issue.id == "1"
      assert issue.key == "ISSUE-4321"
      assert issue.title == "Story title goes here!"
      assert issue.description == "The *description* of the story goes _here_"
      assert issue.team == "My Team"
      assert issue.state == "New"
      assert issue.type == "Story"
      assert issue.labels == ["good-stuff"]
      assert issue.reporter == "Jane Doe"
      assert issue.assignee == "Jane Doe"
      assert issue.story_points == 3
    end
  end

  describe "filter_by_team" do
    test "returns issues with custom team field matching the provided value" do
      unfiltered_issues = [
        %Issue{id: "1", team: "Cool Team"},
        %Issue{id: "2", team: "Meh Team"},
        %Issue{id: "3", team: "Cool Team"},
        %Issue{id: "4"}
      ]

      issues = Issues.filter_by_team(unfiltered_issues, "Cool Team")

      assert Enum.count(issues) == 2
      assert Enum.map(issues, &Map.get(&1, :id)) == ["1", "3"]
    end
  end
end
