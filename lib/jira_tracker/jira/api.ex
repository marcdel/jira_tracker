defmodule JiraTracker.Jira.API do
  use HTTPoison.Base

  alias JiraTracker.Jira.Credentials

  def process_request_url(url) do
    "https://#{Credentials.jira_account()}/rest/api/latest#{url}"
  end

  def process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end

  def process_request_headers(headers) do
    headers ++ ["Content-Type": "application/json"]
  end

  def process_response_body(body), do: Poison.decode!(body)
end
