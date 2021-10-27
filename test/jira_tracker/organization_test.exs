defmodule JiraTracker.OrganizationTest do
  use JiraTracker.DataCase

  alias JiraTracker.Organization

  describe "teams" do
    alias JiraTracker.Organization.Team

    import JiraTracker.OrganizationFixtures

    @invalid_attrs %{name: nil}

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Organization.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{name: "some name", backlog_board_id: "12345"}

      assert {:ok, %Team{} = team} = Organization.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.backlog_board_id == "12345"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Team{} = team} = Organization.update_team(team, update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_team(team, @invalid_attrs)
      assert team == Organization.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Organization.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Organization.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Organization.change_team(team)
    end
  end
end
