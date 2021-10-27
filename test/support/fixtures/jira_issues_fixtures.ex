defmodule JiraTracker.JiraIssuesFixtures do
  def issue_json(fields \\ %{}) do
    Map.merge(
      %{
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
      },
      fields
    )
  end
end
