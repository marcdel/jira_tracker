ExUnit.start()
Faker.start()

Application.put_env(:jira_tracker, :jira, JiraTracker.JiraMock)
Application.put_env(:jira_tracker, :jira_client, JiraTracker.JiraClientMock)

Ecto.Adapters.SQL.Sandbox.mode(JiraTracker.Repo, :manual)
