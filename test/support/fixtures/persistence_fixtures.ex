defmodule JiraTracker.PersistenceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `JiraTracker.Persistence` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        name: Faker.Team.En.name(),
        jira_account: Faker.Internet.domain_name(),
        backlog_open: true,
        icebox_open: true
      })
      |> JiraTracker.Persistence.create_team()

    team
  end

  def team_with_settings_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        name: Faker.Team.En.name(),
        jira_account: Faker.Internet.domain_name(),
        backlog_open: true,
        icebox_open: true
      })
      |> JiraTracker.Persistence.create_team()

    attrs
    |> Map.get(:jira_settings, %{})
    |> Map.put(:team, team)
    |> jira_settings_fixture()

    JiraTracker.Repo.preload(team, :jira_settings)
  end

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    team = team_fixture()

    {:ok, user} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        email: Faker.Internet.email(),
        name: Faker.Person.name()
      })
      |> JiraTracker.Persistence.create_user()

    user
  end

  @doc """
  Generate a unique story jira_key.
  """
  def unique_story_key, do: "ISSUE-#{System.unique_integer([:positive])}"

  @doc """
  Generate a story.
  """
  def story_fixture(attrs \\ %{}) do
    team = Map.get(attrs, :team, team_fixture())
    reporter = user_fixture()
    assignee = user_fixture()

    {:ok, story} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        reporter_id: reporter.id,
        assignee_id: assignee.id,
        description: "some description",
        jira_key: unique_story_key(),
        labels: ["label 1", "label 2"],
        state: "some state",
        points: 42,
        title: "some title",
        type: "some type",
        in_backlog: true
      })
      |> JiraTracker.Persistence.create_story()

    story
  end

  @doc """
  Generate a jira_settings.
  """
  def jira_settings_fixture(attrs \\ %{}) do
    team = Map.get(attrs, :team, team_fixture())

    {:ok, jira_settings} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        account_url: "some account_url",
        issues_jql: "some issues_jql",
        story_point_field: "some story_point_field"
      })
      |> JiraTracker.Persistence.create_jira_settings()

    jira_settings
  end
end
