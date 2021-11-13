defmodule JiraTracker.Story do
  defstruct [
    :id,
    :jira_key,
    :title,
    :description,
    :team,
    :state,
    :type,
    :labels,
    :reporter,
    :assignee,
    :points
  ]
end
