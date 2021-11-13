defmodule JiraTracker.PersistenceTest do
  use JiraTracker.DataCase

  alias JiraTracker.Persistence

  describe "teams" do
    alias JiraTracker.Persistence.Team

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{name: nil, jira_account: nil, backlog_board_id: nil}

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Persistence.get_team!(team.id) == team
    end

    test "get_team_by_name/1 returns the team with given name" do
      team = team_fixture()
      assert Persistence.get_team_by_name(team.name) == team
      assert Persistence.get_team_by_name("mystery team") == nil
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{
        name: "some name",
        jira_account: "acme.atlassian.net",
        backlog_board_id: 12345
      }

      assert {:ok, %Team{} = team} = Persistence.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.jira_account == "acme.atlassian.net"
      assert team.backlog_board_id == 12345
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name", backlog_board_id: 54321}

      assert {:ok, %Team{} = team} = Persistence.update_team(team, update_attrs)
      assert team.name == "some updated name"
      assert team.backlog_board_id == 54321
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

  describe "stories" do
    alias JiraTracker.Persistence.Story

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{
      description: nil,
      jira_key: nil,
      labels: nil,
      state: nil,
      points: nil,
      title: nil,
      type: nil
    }

    test "list_stories/1 returns all stories" do
      team = team_fixture()
      other_team = team_fixture()

      backlog_story = story_fixture(%{team_id: team.id, in_backlog: true})
      icebox_story = story_fixture(%{team_id: team.id, in_backlog: false})
      other_team_story = story_fixture(%{team_id: other_team.id, in_backlog: true})

      assert Persistence.list_stories(team.id, in_backlog: true) == [backlog_story]
      assert Persistence.list_stories(team.id, in_backlog: false) == [icebox_story]
      assert Persistence.list_stories(other_team.id, in_backlog: true) == [other_team_story]
    end

    test "get_story/1 returns the story with given id" do
      story = story_fixture()
      assert Persistence.get_story(story.id) == story
    end

    test "get_story_by_key/1 returns the story with given id" do
      story = story_fixture()
      assert Persistence.get_story_by_key(story.jira_key) == story
    end

    test "create_story/1 with valid data creates a story" do
      team = team_fixture()
      reporter = user_fixture()
      assignee = user_fixture()

      valid_attrs = %{
        team_id: team.id,
        reporter_id: reporter.id,
        assignee_id: assignee.id,
        description: "some description",
        jira_key: "some jira_key",
        labels: ["beep", "boop"],
        state: "some state",
        points: 42,
        title: "some title",
        type: "some type"
      }

      assert {:ok, %Story{} = story} = Persistence.create_story(valid_attrs)

      assert story.team_id == team.id
      assert story.reporter_id == reporter.id
      assert story.assignee_id == assignee.id
      assert story.in_backlog == false
      assert story.description == "some description"
      assert story.jira_key == "some jira_key"
      assert story.labels == ["beep", "boop"]
      assert story.state == "some state"
      assert story.points == 42
      assert story.title == "some title"
      assert story.type == "some type"
    end

    test "create_story/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_story(@invalid_attrs)
    end

    test "update_story/2 with valid data updates the story" do
      story = story_fixture()

      update_attrs = %{
        description: "some updated description",
        jira_key: "some updated jira_key",
        labels: [],
        state: "some updated state",
        points: 43,
        title: "some updated title",
        type: "some updated type"
      }

      assert {:ok, %Story{} = story} = Persistence.update_story(story, update_attrs)
      assert story.description == "some updated description"
      assert story.jira_key == "some updated jira_key"
      assert story.labels == []
      assert story.state == "some updated state"
      assert story.points == 43
      assert story.title == "some updated title"
      assert story.type == "some updated type"
    end

    test "update_story/2 with invalid data returns error changeset" do
      story = story_fixture()
      assert {:error, %Ecto.Changeset{}} = Persistence.update_story(story, @invalid_attrs)
      assert story == Persistence.get_story(story.id)
    end

    test "delete_story/1 deletes the story" do
      story = story_fixture()
      assert {:ok, %Story{}} = Persistence.delete_story(story)
      assert nil == Persistence.get_story(story.id)
    end

    test "change_story/1 returns a story changeset" do
      story = story_fixture()
      assert %Ecto.Changeset{} = Persistence.change_story(story)
    end
  end
end
