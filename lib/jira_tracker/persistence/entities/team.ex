defmodule JiraTracker.Persistence.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.User
  alias JiraTracker.Persistence.Story
  alias JiraTracker.Persistence.JiraSettings

  schema "teams" do
    field :name, :string
    field :backlog_open, :boolean
    field :icebox_open, :boolean
    has_many :users, User
    has_many :stories, Story
    has_one :jira_settings, JiraSettings

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :name,
      :backlog_open,
      :icebox_open
    ])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
