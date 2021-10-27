defmodule JiraTracker.Jira.Credentials do
  def jira_account, do: Application.get_env(:jira_tracker, :jira_account)
  def jira_username, do: Application.get_env(:jira_tracker, :jira_username)
  def jira_password, do: Application.get_env(:jira_tracker, :jira_password)
end
