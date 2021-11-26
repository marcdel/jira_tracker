defmodule JiraTracker.Repo.Migrations.CreateJiraSettings do
  use Ecto.Migration

  def change do
    create table(:jira_settings) do
      add :story_point_field, :string
      add :issues_jql, :text
      add :account_url, :string
      add :team_id, references(:teams, on_delete: :delete_all)

      timestamps()
    end

    create index(:jira_settings, [:team_id])
  end
end
