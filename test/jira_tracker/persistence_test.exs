defmodule JiraTracker.PersistenceTest do
  use JiraTracker.DataCase

  alias JiraTracker.Persistence

  describe "teams" do
    alias JiraTracker.Persistence.Team

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{name: nil, jira_account: nil, jira_issues_jql: nil}

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Persistence.get_team!(team.id) == team
    end

    test "get_team!/1 preloads the given fields" do
      team = team_fixture()
      settings = jira_settings_fixture(%{team: team})

      %{jira_settings: jira_settings} = Persistence.get_team!(team.id, [:jira_settings])
      assert jira_settings == settings
    end

    test "get_team_by_name/1 returns the team with given name" do
      team = team_fixture()
      assert Persistence.get_team_by_name(team.name) == team
      assert Persistence.get_team_by_name("mystery team") == nil
    end

    test "create_or_get_team/1 creates team when one doesn't exist" do
      valid_attrs = %{
        name: "some name",
        jira_account: "acme.atlassian.net",
        jira_issues_jql: "project = 'ACME' AND type = 'Bug' AND status = 'Open'"
      }

      assert {:ok, team} = Persistence.create_or_get_team(valid_attrs)
      assert team.id != nil
    end

    test "create_or_get_team/1 returns the existing team and discards updates when exists" do
      existing_team =
        team_fixture(%{
          name: "some name",
          jira_account: "acme.atlassian.net",
          jira_issues_jql: "project = 'ACME' AND type = 'Bug' AND status = 'Open'"
        })

      valid_attrs = %{
        name: "some name",
        jira_account: "acme.atlassian.net",
        jira_issues_jql: "project = 'BEEPBOOP'"
      }

      assert {:ok, team} = Persistence.create_or_get_team(valid_attrs)
      assert team.id == existing_team.id
      assert team.name == "some name"
      assert team.jira_account == "acme.atlassian.net"
      assert team.jira_issues_jql == "project = 'ACME' AND type = 'Bug' AND status = 'Open'"
    end

    test "create_or_get_team/1 returns an error tuple when invalid" do
      assert {:error, _} = Persistence.create_or_get_team(@invalid_attrs)
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{
        name: "some name",
        jira_account: "acme.atlassian.net",
        jira_issues_jql: "project = 'ACME' AND type = 'Bug' AND status = 'Open'"
      }

      assert {:ok, %Team{} = team} = Persistence.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.jira_account == "acme.atlassian.net"
      assert team.jira_issues_jql == "project = 'ACME' AND type = 'Bug' AND status = 'Open'"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{name: "some updated name", icebox_open: false}

      assert {:ok, %Team{} = team} = Persistence.update_team(team, update_attrs)
      assert team.name == "some updated name"
      assert team.icebox_open == false
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

    test "create_or_get_user/1 creates user when one doesn't exist" do
      team = team_fixture()
      valid_attrs = %{team_id: team.id, email: "some email", name: "some name"}
      assert {:ok, user} = Persistence.create_or_get_user(valid_attrs)
      assert user.id != nil
    end

    test "create_or_get_user/1 returns the existing user and discards updates when exists" do
      team = team_fixture()
      existing_user = user_fixture(%{team_id: team.id, email: "some email", name: "some name"})
      valid_attrs = %{team_id: team.id, email: "some email", name: "new name"}
      assert {:ok, user} = Persistence.create_or_get_user(valid_attrs)
      assert user.id == existing_user.id
      assert user.email == "some email"
      assert user.name == "some name"
    end

    test "create_or_get_user/1 returns an error tuple when invalid" do
      assert {:error, _} = Persistence.create_or_get_user(@invalid_attrs)
    end

    test "create_user/1 with valid data creates a user" do
      team = team_fixture()
      valid_attrs = %{team_id: team.id, email: "some email", name: "some name"}

      assert {:ok, %User{} = user} = Persistence.create_user(valid_attrs)
      assert user.id != nil
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

  describe "jira_settings" do
    alias JiraTracker.Persistence.JiraSettings

    import JiraTracker.PersistenceFixtures

    @invalid_attrs %{account_url: nil, issues_jql: nil, story_point_field: nil}

    test "get_jira_settings!/1 returns the jira_settings with given id" do
      jira_settings = jira_settings_fixture()
      assert Persistence.get_jira_settings!(jira_settings.id) == jira_settings
    end

    test "create_jira_settings/1 with valid data creates a jira_settings" do
      team = team_fixture()

      valid_attrs = %{
        team_id: team.id,
        account_url: "some account_url",
        issues_jql: "some issues_jql",
        story_point_field: "some story_point_field"
      }

      assert {:ok, %JiraSettings{} = jira_settings} =
               Persistence.create_jira_settings(valid_attrs)

      assert jira_settings.account_url == "some account_url"
      assert jira_settings.issues_jql == "some issues_jql"
      assert jira_settings.story_point_field == "some story_point_field"
    end

    test "create_jira_settings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Persistence.create_jira_settings(@invalid_attrs)
    end

    test "update_jira_settings/2 with valid data updates the jira_settings" do
      jira_settings = jira_settings_fixture()

      update_attrs = %{
        account_url: "some updated account_url",
        issues_jql: "some updated issues_jql",
        story_point_field: "some updated story_point_field"
      }

      assert {:ok, %JiraSettings{} = jira_settings} =
               Persistence.update_jira_settings(jira_settings, update_attrs)

      assert jira_settings.account_url == "some updated account_url"
      assert jira_settings.issues_jql == "some updated issues_jql"
      assert jira_settings.story_point_field == "some updated story_point_field"
    end

    test "update_jira_settings/2 with invalid data returns error changeset" do
      jira_settings = jira_settings_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Persistence.update_jira_settings(jira_settings, @invalid_attrs)

      assert jira_settings == Persistence.get_jira_settings!(jira_settings.id)
    end

    test "delete_jira_settings/1 deletes the jira_settings" do
      jira_settings = jira_settings_fixture()
      assert {:ok, %JiraSettings{}} = Persistence.delete_jira_settings(jira_settings)
      assert_raise Ecto.NoResultsError, fn -> Persistence.get_jira_settings!(jira_settings.id) end
    end

    test "change_jira_settings/1 returns a jira_settings changeset" do
      jira_settings = jira_settings_fixture()
      assert %Ecto.Changeset{} = Persistence.change_jira_settings(jira_settings)
    end
  end
end
