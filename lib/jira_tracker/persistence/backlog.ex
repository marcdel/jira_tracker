defmodule JiraTracker.Persistence.Backlog do
  import Ecto.Query, warn: false
  alias JiraTracker.Persistence.Story
  alias JiraTracker.Repo

  def stories(%{id: team_id}) do
    query = from story in Story, where: story.team_id == ^team_id and story.in_backlog == true
    Repo.all(query)
  end
end
