defmodule JiraTracker.Backlog do
  use OpenTelemetryDecorator

  alias JiraTracker.Jira
  alias JiraTracker.Persistence.Backlog, as: DbBacklog

  defstruct stories: []

  @decorate trace("JiraTracker.Backlog.refresh")
  def refresh(team) do
    {:ok, unsaved_stories} = Jira.backlog(team.backlog_board_id)
    DbBacklog.add_new_stories(team, unsaved_stories)

    get(team)
  end

  @decorate trace("JiraTracker.Backlog.get")
  def get(team) do
    %__MODULE__{stories: DbBacklog.stories(team)}
  end
end
