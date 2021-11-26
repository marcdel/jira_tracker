defmodule JiraTracker.Persistence.JiraSettings do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.Team

  schema "jira_settings" do
    field :account_url, :string
    field :issues_jql, :string
    field :story_point_field, :string
    belongs_to :team, Team

    timestamps()
  end

  @doc false
  def changeset(jira_settings, attrs) do
    jira_settings
    |> cast(attrs, [:team_id, :story_point_field, :issues_jql, :account_url])
    |> validate_required([:team_id, :issues_jql, :account_url])
  end
end
