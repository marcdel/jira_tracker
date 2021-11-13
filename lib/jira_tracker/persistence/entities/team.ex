defmodule JiraTracker.Persistence.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.User

  schema "teams" do
    field :name, :string
    field :jira_account, :string
    field :backlog_board_id, :integer
    has_many :users, User

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :jira_account, :backlog_board_id])
    |> validate_required([:name, :jira_account, :backlog_board_id])
    |> unique_constraint([:name, :jira_account])
  end
end
