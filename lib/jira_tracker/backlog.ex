defmodule JiraTracker.Backlog do
  use OpenTelemetryDecorator

  alias JiraTracker.Persistence.Backlog, as: DbBacklog

  defstruct stories: []

  @decorate trace("JiraTracker.Backlog.get")
  def get(team) do
    %__MODULE__{stories: DbBacklog.stories(team)}
  end
end
