defmodule JiraTracker.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :jira_account, :string
      add :backlog_board_id, :integer

      timestamps()
    end

    create unique_index(:teams, [:name, :jira_account])
  end
end
