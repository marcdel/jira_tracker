defmodule JiraTracker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :team_id, references(:teams, on_delete: :nothing)

      timestamps()
    end

    create index(:users, [:team_id])
  end
end
