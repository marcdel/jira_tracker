defmodule JiraTracker.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :backlog_board_id, :string

      timestamps()
    end
  end
end
