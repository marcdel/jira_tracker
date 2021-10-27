defmodule JiraTrackerWeb.TeamLiveTest do
  use JiraTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import JiraTracker.OrganizationFixtures

  defp create_team(_) do
    team = team_fixture()
    %{team: team}
  end

  describe "Show" do
    setup [:create_team]

    # TODO: define interface for jira client and mock
    @tag :skip
    test "displays team", %{conn: conn, team: team} do
      {:ok, _show_live, html} = live(conn, Routes.team_show_path(conn, :show, team))

      assert html =~ team.name
    end
  end
end
