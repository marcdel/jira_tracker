defmodule JiraTrackerWeb.PageControllerTest do
  use JiraTrackerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = conn
           |> put_req_header("authorization", "Basic " <> Base.encode64("admin:admin"))
           |> get("/")

    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
