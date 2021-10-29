defmodule JiraTracker.PersistenceTest do
  use JiraTracker.DataCase

  alias JiraTracker.Persistence

  describe "teams" do
    alias JiraTracker.Persistence.TeamRecord

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{name: nil}

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Persistence.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{name: "some name", backlog_board_id: "12345"}

      assert {:ok, %TeamRecord{} = team} = Persistence.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.backlog_board_id == "12345"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %TeamRecord{} = team} = Persistence.update_team(team, update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Persistence.update_team(team, @invalid_attrs)
      assert team == Persistence.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %TeamRecord{}} = Persistence.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Persistence.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Persistence.change_team(team)
    end
  end
end
