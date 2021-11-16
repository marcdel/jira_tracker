defmodule JiraTracker.Team do
  alias JiraTracker.Backlog
  alias JiraTracker.Icebox
  alias JiraTracker.Persistence

  def get!(id), do: Persistence.get_team!(id)

  def refresh(team) do
    %{backlog: Backlog.refresh(team), icebox: Icebox.refresh(team)}
  end

  def backlog(team) do
    case Backlog.get(team) do
      %{stories: []} -> Backlog.refresh(team)
      backlog -> backlog
    end
  end

  def icebox(team) do
    case Icebox.get(team) do
      %{stories: []} -> Icebox.refresh(team)
      icebox -> icebox
    end
  end
end
