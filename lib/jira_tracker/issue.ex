defmodule JiraTracker.Issue do
  defstruct [:id, :key, :title, :description, :team, :state, :type, :labels]
end
