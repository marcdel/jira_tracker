defmodule JiraTracker.Persistence.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.User
  alias JiraTracker.Persistence.Story

  schema "teams" do
    field :name, :string
    field :jira_account, :string
    field :backlog_board_id, :integer
    field :jira_issues_jql, :string
    has_many :users, User
    has_many :stories, Story

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :jira_account, :backlog_board_id, :jira_issues_jql])
    |> validate_required([:name, :jira_account, :jira_issues_jql])
    |> unique_constraint([:name, :jira_account])
  end
end
