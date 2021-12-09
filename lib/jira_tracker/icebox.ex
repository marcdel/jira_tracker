defmodule JiraTracker.Icebox do
  use OpenTelemetryDecorator

  alias JiraTracker.Persistence.Icebox, as: DbIcebox

  defstruct stories: []

  @decorate trace("JiraTracker.Icebox.refresh")
  def refresh(team) do
    {:ok, unsaved_stories} = jira().fetch_issues(team)
    DbIcebox.add_new_stories(team, unsaved_stories)

    %{team.icebox | stories: DbIcebox.stories(team)}
  end

  @decorate trace("JiraTracker.Icebox.get")
  def get(team) do
    %__MODULE__{stories: DbIcebox.stories(team)}
  end

  defp jira do
    Application.get_env(:jira_tracker, :jira)
  end
end
