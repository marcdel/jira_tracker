defmodule JiraTracker.Persistence do
  @moduledoc """
  The Persistence context.
  """

  import Ecto.Query, warn: false
  alias JiraTracker.Repo

  alias JiraTracker.Persistence.TeamRecord

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(TeamRecord, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %TeamRecord{}
    |> TeamRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %TeamRecord{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%TeamRecord{} = team, attrs) do
    team
    |> TeamRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeamRecord.

  ## Examples

      iex> delete_team(TeamRecord)
      {:ok, %TeamRecord{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%TeamRecord{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %TeamRecord{}}

  """
  def change_team(%TeamRecord{} = team, attrs \\ %{}) do
    TeamRecord.changeset(team, attrs)
  end
end
