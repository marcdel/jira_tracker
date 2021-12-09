# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     JiraTracker.Repo.insert!(%JiraTracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _} =
  JiraTracker.Team.create(%{
    name: "Teamsters",
    jira_issues_jql: "order by created DESC",
    account_url: "solid-af.atlassian.net"
  })
