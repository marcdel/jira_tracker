defmodule JiraTracker.Repo.Migrations.RemoveJiraSettingFromTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      remove :jira_account, :string, default: ""
      remove :jira_issues_jql, :string, default: ""
    end
  end
end
