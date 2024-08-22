defmodule PracticeMateWeb.PageController do
  use PracticeMateWeb, :controller

  alias PracticeMate.Spotify

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect = Spotify.authorize_url()
    redirect(conn, external: redirect)
  end

  def spotify(conn, params) do
    PracticeMate.save_authorization(params["code"])

    text(conn, "Success. You may now close your Browser and play spotify via iex")
  end
end
