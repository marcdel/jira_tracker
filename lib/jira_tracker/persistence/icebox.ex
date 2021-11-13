defmodule JiraTracker.Persistence.Icebox do
  import Ecto.Query, warn: false
  use OpenTelemetryDecorator

  alias JiraTracker.Persistence.Story
  alias JiraTracker.Repo

  @doc """
  Returns all stories in the icebox.

  ## Examples

      iex> stories(%Team{})
      [%Story{}, %Story{}]

  """
  def stories(%{id: team_id}) do
    query = from story in Story, where: story.team_id == ^team_id and story.in_backlog == false
    Repo.all(query)
  end

  @doc """
  Adds new stories to the icebox. Existing stories are returned unmodified.

  ## Examples

      iex> add_new_stories(%Team{}, [%{field: new_value}, %{field: existing_value}])
      [{:ok, %Story{}}, {:ok, %Story{}}]

      iex> add_new_stories(%Team{}, [%{field: bad_value}])
      [{:error, %Ecto.Changeset{}}]

  """
  @decorate trace("JiraTracker.Persistence.Icebox.add_new_stories", include: [:team_id])
  def add_new_stories(%{id: team_id}, story_attrs) do
    stories =
      Enum.map(story_attrs, fn attrs ->
        Story.changeset(%Story{}, Map.put(attrs, :team_id, team_id))
      end)

    results = Enum.map(stories, &Repo.insert(&1, on_conflict: :nothing))

    report_results(results)

    results
  end

  defp report_results(results) do
    {successes, errors} =
      Enum.split_with(results, fn
        {:ok, _} -> true
        _ -> false
      end)

    O11y.span_attributes(error_count: Enum.count(errors), success_count: Enum.count(successes))

    results
  end
end
