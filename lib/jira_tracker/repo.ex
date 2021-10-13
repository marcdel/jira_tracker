defmodule JiraTracker.Repo do
  use Ecto.Repo,
    otp_app: :jira_tracker,
    adapter: Ecto.Adapters.Postgres
end
