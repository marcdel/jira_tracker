defmodule JiraTracker.Icebox do
  use OpenTelemetryDecorator

  alias JiraTracker.Jira
  alias JiraTracker.Persistence.Icebox, as: DbIcebox

  defstruct open: false, stories: []

  @decorate trace("JiraTracker.Icebox.refresh")
  def refresh(team) do
    {:ok, unsaved_stories} = Jira.fetch_issues(team)
    DbIcebox.add_new_stories(team, unsaved_stories)

    get(team)
  end

  @decorate trace("JiraTracker.Icebox.get")
  def get(team) do
    %__MODULE__{stories: DbIcebox.stories(team)}
  end
end
