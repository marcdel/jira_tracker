defmodule JiraTracker.Persistence.Story do
  use Ecto.Schema
  import Ecto.Changeset

  alias JiraTracker.Persistence.Team
  alias JiraTracker.Persistence.User

  schema "stories" do
    field :description, :string
    field :jira_key, :string
    field :labels, {:array, :string}
    field :state, :string
    field :story_points, :integer
    field :title, :string
    field :type, :string
    field :in_backlog, :boolean, default: false
    belongs_to :team, Team
    belongs_to :reporter, User
    belongs_to :assignee, User

    timestamps()
  end

  @doc false
  def changeset(story, attrs) do
    story
    |> cast(attrs, [
      :team_id,
      :reporter_id,
      :assignee_id,
      :jira_key,
      :title,
      :description,
      :state,
      :type,
      :labels,
      :story_points,
      :in_backlog
    ])
    |> validate_required([:team_id, :jira_key, :title, :state, :type])
    |> unique_constraint(:jira_key)
  end
end
