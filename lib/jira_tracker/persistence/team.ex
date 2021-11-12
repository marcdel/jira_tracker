defmodule JiraTracker.Persistence.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.User

  schema "teams" do
    field :name, :string
    field :backlog_board_id, :string
    has_many :users, User

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :backlog_board_id])
    |> validate_required([:name, :backlog_board_id])
  end
end
