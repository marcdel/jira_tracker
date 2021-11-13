defmodule JiraTracker.Persistence.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.Team

  schema "users" do
    field :email, :string
    field :name, :string
    belongs_to :team, Team

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :team_id])
    |> validate_required([:name, :email, :team_id])
    |> unique_constraint(:email)
  end
end
