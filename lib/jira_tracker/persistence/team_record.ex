defmodule JiraTracker.Persistence.TeamRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    field :backlog_board_id, :string

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :backlog_board_id])
    |> validate_required([:name, :backlog_board_id])
  end
end
