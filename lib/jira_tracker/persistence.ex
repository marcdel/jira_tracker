defmodule JiraTracker.Persistence do
  @moduledoc """
  The Persistence context.
  """

  import Ecto.Query, warn: false
  alias JiraTracker.Repo

  alias JiraTracker.Persistence.Team

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  def get_team!(id, preloads) do
    Team
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single team by name.

  Returns nil if the Team does not exist.

  ## Examples

      iex> get_team_by_name("Joe Dirt")
      %Team{}

      iex> get_team_by_name("Bob Smith")
      nil

  """
  def get_team_by_name(name), do: Repo.get_by(Team, name: name)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(Team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  alias JiraTracker.Persistence.User

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by name.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_name("Joe Dirt")
      %User{}

      iex> get_user_by_name("Bob Smith")
      nil

  """
  def get_user_by_name(name), do: Repo.get_by(User, name: name)

  @doc """
  Gets a single user by email.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_email("joe.dirt@email.com")
      %User{}

      iex> get_user_by_email("bob.smith@email.com")
      nil

  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Creates a user or get the existing one.

  The create_user/1 function uses the [on_conflict: :nothing] option
  to avoid creating duplicate users, so if an :id is not created, we
  look up the user by the unique key to ensure we have the correct data.

  ## Examples

      iex> create_or_get_user(%{field: value})
      {:ok, %User{}}

      iex> create_or_get_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_get_user(attrs \\ %{}) do
    case create_user(attrs) do
      {:ok, %{id: nil, email: email}} -> {:ok, get_user_by_email(email)}
      {:ok, user} -> {:ok, user}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  alias JiraTracker.Persistence.Story

  @doc """
  Returns the list of stories.

  ## Examples

      iex> list_stories()
      [%Story{}, ...]

  """
  def list_stories(team_id, in_backlog: in_backlog) do
    query =
      from story in Story, where: story.team_id == ^team_id and story.in_backlog == ^in_backlog

    Repo.all(query)
  end

  @doc """
  Gets a single story.

  Returns nil if the Story does not exist.

  ## Examples

      iex> get_story(123)
      %Story{}

      iex> get_story(456)
      nil

  """
  def get_story(id), do: Repo.get(Story, id)

  def get_story!(id), do: Repo.get!(Story, id)

  @doc """
  Gets a single story.

  Returns nil if the Story does not exist.

  ## Examples

      iex> get_story_by_key(123)
      %Story{}

      iex> get_story_by_key(456)
      nil

  """
  def get_story_by_key(jira_key), do: Repo.get_by(Story, jira_key: jira_key)

  @doc """
  Creates a story.

  ## Examples

      iex> create_story(%{field: value})
      {:ok, %Story{}}

      iex> create_story(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_story(attrs \\ %{}) do
    %Story{}
    |> Story.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a story.

  ## Examples

      iex> update_story(story, %{field: new_value})
      {:ok, %Story{}}

      iex> update_story(story, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_story(%Story{} = story, attrs) do
    story
    |> Story.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a story.

  ## Examples

      iex> delete_story(story)
      {:ok, %Story{}}

      iex> delete_story(story)
      {:error, %Ecto.Changeset{}}

  """
  def delete_story(%Story{} = story) do
    Repo.delete(story)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking story changes.

  ## Examples

      iex> change_story(story)
      %Ecto.Changeset{data: %Story{}}

  """
  def change_story(%Story{} = story, attrs \\ %{}) do
    Story.changeset(story, attrs)
  end

  alias JiraTracker.Persistence.JiraSettings

  @doc """
  Gets a single jira_settings.

  Raises `Ecto.NoResultsError` if the Jira settings does not exist.

  ## Examples

      iex> get_jira_settings!(123)
      %JiraSettings{}

      iex> get_jira_settings!(456)
      ** (Ecto.NoResultsError)

  """
  def get_jira_settings!(id), do: Repo.get!(JiraSettings, id)

  @doc """
  Creates a jira_settings.

  ## Examples

      iex> create_jira_settings(%{field: value})
      {:ok, %JiraSettings{}}

      iex> create_jira_settings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_jira_settings(attrs \\ %{}) do
    %JiraSettings{}
    |> JiraSettings.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a jira_settings.

  ## Examples

      iex> update_jira_settings(jira_settings, %{field: new_value})
      {:ok, %JiraSettings{}}

      iex> update_jira_settings(jira_settings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_jira_settings(%JiraSettings{} = jira_settings, attrs) do
    jira_settings
    |> JiraSettings.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a jira_settings.

  ## Examples

      iex> delete_jira_settings(jira_settings)
      {:ok, %JiraSettings{}}

      iex> delete_jira_settings(jira_settings)
      {:error, %Ecto.Changeset{}}

  """
  def delete_jira_settings(%JiraSettings{} = jira_settings) do
    Repo.delete(jira_settings)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking jira_settings changes.

  ## Examples

      iex> change_jira_settings(jira_settings)
      %Ecto.Changeset{data: %JiraSettings{}}

  """
  def change_jira_settings(%JiraSettings{} = jira_settings, attrs \\ %{}) do
    JiraSettings.changeset(jira_settings, attrs)
  end
end
