defmodule PracticeMateWeb.PageControllerTest do
  use PracticeMateWeb.ConnCase

  test "GET / redirects to spotify authorization", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 302) =~
             "You are being <a href=\"https://localhost.spotify.com/logmein\">redirected</a>"
  end
end
