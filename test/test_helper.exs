ExUnit.start()
Faker.start()
Application.put_env(:jira_tracker, :jira, JiraTracker.JiraMock)
Ecto.Adapters.SQL.Sandbox.mode(JiraTracker.Repo, :manual)
