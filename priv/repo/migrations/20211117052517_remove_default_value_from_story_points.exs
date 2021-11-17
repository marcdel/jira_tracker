defmodule JiraTracker.Repo.Migrations.RemoveDefaultValueFromStoryPoints do
  use Ecto.Migration

  def change do
    alter table(:stories) do
      modify :points, :integer, default: nil
    end
  end
end
