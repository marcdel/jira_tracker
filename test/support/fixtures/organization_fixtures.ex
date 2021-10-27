defmodule JiraTracker.OrganizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `JiraTracker.Organization` context.
  """

  import Ecto

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        name: "some name",
        backlog_board_id: Ecto.UUID.generate()
      })
      |> JiraTracker.Organization.create_team()

    team
  end
end
