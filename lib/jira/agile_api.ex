defmodule Jira.AgileAPI do
  use HTTPoison.Base

  alias Jira.Credentials

  def process_request_url(url) do
    "https://#{Credentials.jira_account()}/rest/agile/latest#{url}"
  end

  def process_request_headers(headers) when is_map(headers) do
    Enum.into(headers, [])
  end

  def process_request_headers(headers) do
    headers ++ ["Content-Type": "application/json"]
  end

  def process_response_body(body), do: Poison.decode!(body)
end
