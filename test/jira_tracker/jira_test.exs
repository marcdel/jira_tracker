defmodule JiraTracker.JiraTest do
  use ExUnit.Case

  alias JiraTracker.Jira

  describe "fetch_issues" do
    test "fetches issues for the given project" do
      get_issues = fn
        "1234" -> {:ok, [%{}, %{}]}
        id -> raise "expected to be called with 1234 as a string, but was called with #{id}"
      end

      {:ok, issues} = Jira.fetch_issues(1234, get_issues)

      assert Enum.count(issues) == 2
    end
  end
end
