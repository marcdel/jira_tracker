defmodule JiraTracker.Repo.Migrations.AddBacklogIceboxOpenToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :icebox_open, :boolean, default: true
      add :backlog_open, :boolean, default: true
    end
  end
end
