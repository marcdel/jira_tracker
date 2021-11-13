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
        name: "some name",
        jira_account: "acme.atlassian.net",
        backlog_board_id: Enum.random(0..1000)
      })
      |> JiraTracker.Persistence.create_team()

    team
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
        email: "some email",
        name: "some name"
      })
      |> JiraTracker.Persistence.create_user()

    user
  end

  @doc """
  Generate a unique story jira_key.
  """
  def unique_story_jira_key, do: "ISSUE-#{System.unique_integer([:positive])}"

  @doc """
  Generate a story.
  """
  def story_fixture(attrs \\ %{}) do
    team = team_fixture()
    reporter = user_fixture()
    assignee = user_fixture()

    {:ok, story} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        reporter_id: reporter.id,
        assignee_id: assignee.id,
        description: "some description",
        jira_key: unique_story_jira_key(),
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
end
