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
end
