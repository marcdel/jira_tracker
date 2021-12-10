defmodule Jira.Client do
  use OpenTelemetryDecorator
  require Logger

  alias Jira.API
  alias Jira.Credentials

  @type jql :: String.t()
  @type issue_json :: map()

  @type key :: String.t()
  @type fields :: map()

  @callback search(jql) :: {:ok, list(issue_json)} | {:error, any()}
  @callback custom_fields() :: {:ok, map()} | {:error, any()}
  @callback update(key, fields) :: :ok | :error

  @decorate trace("Jira.Client.search", include: [:jql, :url])
  def search(jql) do
    url = "/search?jql=#{URI.encode(jql)}"
    O11y.add_span_attributes(url: url)

    case API.get(url, auth_header()) do
      {:ok, response} ->
        issues =
          response
          |> Map.get(:body)
          |> Map.get("issues", [])

        O11y.add_span_attributes(issues_count: Enum.count(issues))

        {:ok, issues}

      error ->
        O11y.add_span_attributes(status_code: 500)
        Logger.error(inspect(error))
        error
    end
  end

  @decorate trace("Jira.Client.custom_fields")
  def custom_fields do
    case API.get("/field", auth_header()) do
      {:ok, response} ->
        {:ok, Map.get(response, :body, [])}

      error ->
        Logger.error(inspect(error))
        error
    end
  end

  @decorate trace("Jira.Client.update", include: [:issue_key])
  def update(issue_key, fields) do
    body = Poison.encode!(%{fields: fields})

    case API.put("/issue/#{issue_key}", body, auth_header()) do
      {:ok, %{status_code: 204}} ->
        :ok

      # idk lol
      {:ok, response} ->
        Logger.error(inspect(response))
        :error

      error ->
        Logger.error(inspect(error))
        :error
    end
  end

  def auth_header() do
    auth_header(%{
      jira_username: Credentials.jira_username(),
      jira_password: Credentials.jira_password()
    })
  end

  defp auth_header(%{jira_username: username, jira_password: password}) do
    basic_auth = Base.encode64("#{username}:#{password}")
    [Authorization: "Basic #{basic_auth}"]
  end
end
