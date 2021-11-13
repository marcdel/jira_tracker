defmodule JiraTracker.Repo.Migrations.CreateStories do
  use Ecto.Migration

  def change do
    create table(:stories) do
      add :jira_key, :string
      add :title, :string
      add :description, :string
      add :state, :string
      add :type, :string
      add :labels, {:array, :string}
      add :points, :integer
      add :in_backlog, :boolean, default: false
      add :team_id, references(:teams, on_delete: :nothing)
      add :reporter_id, references(:users, on_delete: :nothing)
      add :assignee_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:stories, [:jira_key])
    create index(:stories, [:team_id])
    create index(:stories, [:reporter_id])
    create index(:stories, [:assignee_id])
  end
end
