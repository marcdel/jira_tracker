defmodule JiraTracker.Story do
  defstruct [
    :id,
    :key,
    :title,
    :description,
    :team,
    :state,
    :type,
    :labels,
    :reporter,
    :assignee,
    :story_points
  ]
end
