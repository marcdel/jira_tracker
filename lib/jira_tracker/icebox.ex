defmodule JiraTracker.Icebox do
  use OpenTelemetryDecorator

  alias JiraTracker.Jira
  alias JiraTracker.Persistence.Icebox, as: DbIcebox

  defstruct [stories: []]

  @decorate trace("JiraTracker.Icebox.refresh")
  def refresh(team) do
    {:ok, unsaved_stories} = Jira.other_stories(team.name)
    DbIcebox.add_new_stories(team, unsaved_stories)

    get(team)
  end

  @decorate trace("JiraTracker.Icebox.get")
  def get(team) do
    %__MODULE__{stories: DbIcebox.stories(team)}
  end
end