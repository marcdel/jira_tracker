defmodule JiraTracker.Repo.Migrations.AddJiraIssuesJqlToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :jira_issues_jql, :text
    end
  end
end
