defmodule JiraTrackerWeb.PageController do
  use JiraTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
