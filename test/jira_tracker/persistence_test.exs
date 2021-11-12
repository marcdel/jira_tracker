defmodule JiraTracker.PersistenceTest do
  use JiraTracker.DataCase

  alias JiraTracker.Persistence

  describe "teams" do
    alias JiraTracker.Persistence.Team

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{name: nil}

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Persistence.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{name: "some name", backlog_board_id: "12345"}

      assert {:ok, %Team{} = team} = Persistence.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.backlog_board_id == "12345"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Team{} = team} = Persistence.update_team(team, update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Persistence.update_team(team, @invalid_attrs)
      assert team == Persistence.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Persistence.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Persistence.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Persistence.change_team(team)
    end
  end

  describe "users" do
    alias JiraTracker.Persistence.User

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{team_id: nil, email: nil, name: nil}

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Persistence.get_user(user.id) == user
      assert Persistence.get_user(54321) == nil
    end

    test "get_user_by_name/1 returns the user with given name" do
      user = user_fixture()
      assert Persistence.get_user_by_name(user.name) == user
      assert Persistence.get_user_by_name("beep boopington") == nil
    end

    test "create_user/1 with valid data creates a user" do
      team = team_fixture()
      valid_attrs = %{team_id: team.id, email: "some email", name: "some name"}

      assert {:ok, %User{} = user} = Persistence.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_user(@invalid_attrs)
    end
  end
end
